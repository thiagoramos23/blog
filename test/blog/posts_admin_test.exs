defmodule Blog.PostsAdminTest do
  use Blog.DataCase, async: true

  alias Blog.Posts

  describe "admin article writing" do
    test "create_article/1 creates an admin article from rich HTML" do
      attrs = %{
        title: "Hello Phoenix Admin",
        slug: "",
        summary: "",
        author: "Thiago Ramos",
        date: ~D[2026-03-24],
        body_html: "<div><strong>Hello</strong> world from the editor.</div>"
      }

      assert {:ok, article} = Posts.create_article(attrs)

      assert article.source == "admin"
      assert article.slug == "hello-phoenix-admin"
      assert article.body == "Hello world from the editor."
      assert article.summary == "Hello world from the editor."
      assert article.html_body =~ "<strong>Hello</strong>"
      assert article.html_url == "/articles/hello-phoenix-admin"
      assert article.hash_id
      assert article.category_id == Posts.get_category_by_slug("posts").id
    end

    test "update_article/2 updates admin-authored content without changing hash id" do
      {:ok, article} =
        Posts.create_article(%{
          title: "Original Title",
          slug: "original-title",
          summary: "Original summary",
          author: "Thiago Ramos",
          date: ~D[2026-03-24],
          body_html: "<p>Original body</p>"
        })

      assert {:ok, updated_article} =
               Posts.update_article(article, %{
                 title: "Updated Title",
                 slug: "updated-title",
                 summary: "Updated summary",
                 author: "Thiago Ramos",
                 date: ~D[2026-03-25],
                 body_html: "<p>Updated body</p>"
               })

      assert updated_article.hash_id == article.hash_id
      assert updated_article.source == "admin"
      assert updated_article.slug == "updated-title"
      assert updated_article.body == "Updated body"
      assert updated_article.summary == "Updated summary"
      assert updated_article.html_url == "/articles/updated-title"
      assert updated_article.html_body =~ "Updated body"
    end
  end
end
