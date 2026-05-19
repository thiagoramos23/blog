defmodule Blog.Writer.PostWriterTest do
  use Blog.DataCase, async: true

  alias Blog.Posts
  alias Blog.Posts.Article
  alias Blog.Repo
  alias Blog.Writer.PostWriter

  describe "upsert_articles/1" do
    test "returns an empty list when given no articles" do
      assert PostWriter.upsert_articles([]) == []
    end

    test "inserts a brand-new GitHub article" do
      category = ensure_posts_category!()
      article = build_github_article(slug: "fresh-post", category_id: category.id)

      assert [{:ok, %Article{} = inserted}] = PostWriter.upsert_articles([article])
      assert inserted.slug == "fresh-post"
      assert inserted.source == "github"
      assert Posts.get_article_by_slug("fresh-post").id == inserted.id
    end

    test "updates an existing GitHub article when the hash changes" do
      category = ensure_posts_category!()

      original =
        build_github_article(
          slug: "evolving",
          category_id: category.id,
          hash_id: "hash-v1",
          title: "Original Title",
          body: "Original body"
        )

      assert [{:ok, _}] = PostWriter.upsert_articles([original])

      updated =
        build_github_article(
          slug: "evolving",
          category_id: category.id,
          hash_id: "hash-v2",
          title: "Updated Title",
          body: "Updated body"
        )

      assert [{:ok, %Article{}}] = PostWriter.upsert_articles([updated])

      reloaded = Posts.get_article_by_slug("evolving")
      assert reloaded.title == "Updated Title"
      assert reloaded.body == "Updated body"
      assert reloaded.hash_id == "hash-v2"
      assert Repo.aggregate(Article, :count, :id) == 1
    end

    test "in a mixed batch, skips admin-owned slugs and inserts the rest" do
      {:ok, admin_article} =
        Posts.create_article(%{
          title: "Admin Owned",
          slug: "admin-slug",
          summary: "Admin summary",
          author: "Thiago Ramos",
          date: ~D[2026-03-24],
          body_html: "<p>Admin body</p>"
        })

      category_id = admin_article.category_id

      collides_with_admin =
        build_github_article(
          slug: "admin-slug",
          category_id: category_id,
          title: "GitHub overrides admin?"
        )

      fresh_github =
        build_github_article(
          slug: "github-only",
          category_id: category_id,
          title: "GitHub Only"
        )

      results = PostWriter.upsert_articles([collides_with_admin, fresh_github])

      assert [{:ok, %Article{slug: "github-only"}}] = results

      assert Posts.get_article_by_slug("admin-slug").title == "Admin Owned"
      assert Posts.get_article_by_slug("admin-slug").source == "admin"
      assert Posts.get_article_by_slug("github-only").source == "github"
    end

    test "does not overwrite admin-authored articles" do
      {:ok, article} =
        Posts.create_article(%{
          title: "Admin Owned",
          slug: "shared-slug",
          summary: "Admin summary",
          author: "Thiago Ramos",
          date: ~D[2026-03-24],
          body_html: "<p>Admin body</p>"
        })

      github_article =
        Article.new_post(%{
          title: "GitHub Version",
          slug: article.slug,
          body: "GitHub body",
          html_body: "<p>GitHub body</p>",
          summary: "GitHub summary",
          date: ~D[2026-03-25],
          hash_id: Ecto.UUID.generate(),
          html_url: "https://github.com/example/post",
          author: "GitHub",
          category_id: article.category_id,
          source: "github"
        })

      assert [] = PostWriter.upsert_articles([github_article])

      article = Posts.get_article!(article.id)
      assert article.title == "Admin Owned"
      assert article.body == "Admin body"
      assert article.source == "admin"
    end

    # === YOUR TURN ===
    # Pin down what happens when an individual insert fails at the DB layer.
    # Build a GitHub article that will fail to insert (e.g. a non-existent
    # category_id triggers the FK constraint, or omit a NOT NULL field), pass
    # it through `PostWriter.upsert_articles/1`, and assert on the result.
    #
    # The contract is genuinely ambiguous today — see the guidance in chat.
    @tag :skip
    test "surfaces insert failures without crashing the batch" do
      # TODO: implement
    end
  end

  defp ensure_posts_category!() do
    Posts.get_category_by_slug("posts") ||
      Repo.insert!(%Blog.Posts.Category{name: "Posts", slug: "posts"})
  end

  defp build_github_article(opts) do
    Article.new_post(%{
      title: Keyword.get(opts, :title, "GitHub Title"),
      slug: Keyword.fetch!(opts, :slug),
      body: Keyword.get(opts, :body, "GitHub body"),
      html_body: Keyword.get(opts, :html_body, "<p>GitHub body</p>"),
      summary: Keyword.get(opts, :summary, "GitHub summary"),
      date: Keyword.get(opts, :date, ~D[2026-03-25]),
      hash_id: Keyword.get(opts, :hash_id, Ecto.UUID.generate()),
      html_url: Keyword.get(opts, :html_url, "https://github.com/example/post"),
      author: Keyword.get(opts, :author, "GitHub"),
      category_id: Keyword.fetch!(opts, :category_id),
      source: Keyword.get(opts, :source, "github")
    })
  end
end
