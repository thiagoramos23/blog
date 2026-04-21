defmodule Blog.Writer.PostWriterTest do
  use Blog.DataCase, async: true

  alias Blog.Posts
  alias Blog.Posts.Article
  alias Blog.Writer.PostWriter

  test "upsert_articles/1 does not overwrite admin-authored articles" do
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
end
