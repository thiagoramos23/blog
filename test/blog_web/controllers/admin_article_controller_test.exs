defmodule BlogWeb.AdminArticleControllerTest do
  use BlogWeb.ConnCase, async: true

  alias Blog.Posts.Article
  alias Blog.Posts.Category
  alias Blog.Repo

  describe "admin article pages" do
    test "requires authentication", %{conn: conn} do
      conn = get(conn, "/admin/articles")

      assert redirected_to(conn) == "/admin/admins/log_in"
    end
  end

  describe "authenticated admin article pages" do
    setup :register_and_log_in_admin

    test "authenticated admin can create an article", %{conn: conn} do
      conn =
        conn
        |> post("/admin/articles", %{
          "article" => %{
            "title" => "Admin Post",
            "slug" => "",
            "summary" => "Post summary",
            "author" => "Thiago Ramos",
            "date" => "2026-03-24",
            "html_body" => "<p>Hello from admin</p>"
          }
        })

      assert redirected_to(conn) == "/admin/articles"

      article = Repo.get_by!(Article, slug: "admin-post")
      assert article.title == "Admin Post"
      assert article.source == "admin"
      assert article.html_body =~ "Hello from admin"
    end

    test "authenticated admin can edit an existing article", %{conn: conn} do
      article = article_fixture()

      conn =
        conn
        |> put("/admin/articles/#{article.id}", %{
          "article" => %{
            "title" => "Updated Post",
            "slug" => "updated-post",
            "summary" => "Updated summary",
            "author" => "Thiago Ramos",
            "date" => "2026-03-25",
            "html_body" => "<p>Updated from admin</p>"
          }
        })

      assert redirected_to(conn) == "/admin/articles"

      article = Repo.get!(Article, article.id)
      assert article.title == "Updated Post"
      assert article.slug == "updated-post"
      assert article.html_body =~ "Updated from admin"
    end
  end

  defp article_fixture do
    category =
      Repo.get_by(Category, slug: "posts") ||
        Repo.insert!(Category.changeset(%Category{}, %{name: "Posts", slug: "posts"}))

    Repo.insert!(
      Article.changeset(%Article{}, %{
        title: "Existing Article",
        slug: "existing-article",
        body: "Existing article body",
        html_body: "<p>Existing article body</p>",
        summary: "Existing article body",
        date: ~D[2026-03-24],
        hash_id: Ecto.UUID.generate(),
        html_url: "/articles/existing-article",
        author: "Thiago Ramos",
        category_id: category.id
      })
    )
  end
end
