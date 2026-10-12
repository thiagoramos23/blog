defmodule BlogWeb.ArticleLiveTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest
  import Blog.PostsFixtures

  defp create_article(_) do
    article = article_fixture(%{title: "Current Article", body_html: "<p>Current body</p>"})
    %{article: article}
  end

  test "shows a clear empty state", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert has_element?(view, ".articles-empty", "No articles yet")
  end

  test "the shared header keeps admin account actions", %{conn: conn} do
    article = article_fixture()
    %{conn: conn} = register_and_log_in_admin(%{conn: conn})

    for path <- ["/", "/articles/#{article.slug}", "/apps"] do
      {:ok, view, _html} = live(conn, path)
      assert has_element?(view, ".site-admin-bar a[href='/admin/articles']", "Admin")
      assert has_element?(view, ".site-admin-bar a[href='/admin/admins/settings']", "Settings")
      assert has_element?(view, ".site-admin-bar a[data-method=delete]", "Log out")
    end
  end

  describe "Index" do
    setup [:create_article]

    test "lists published articles", %{conn: conn, article: article} do
      {:ok, index_live, html} = live(conn, "/")

      assert html =~ "Writing on software"
      assert html =~ article.title
      assert html =~ article.summary

      assert has_element?(
               index_live,
               "nav[aria-label='Main navigation'] a[aria-current=page]",
               "Articles"
             )

      assert has_element?(
               index_live,
               ".article-list-item a[href='/articles/#{article.slug}']",
               article.title
             )

      assert has_element?(
               index_live,
               ".article-list-item time[datetime='#{Date.to_iso8601(article.date)}']"
             )
    end
  end

  describe "Show" do
    setup [:create_article]

    test "displays article content", %{conn: conn, article: article} do
      {:ok, show_live, html} = live(conn, "/articles/#{article.slug}")

      assert html =~ article.title
      assert html =~ "min read"
      assert html =~ "Current body"

      assert has_element?(
               show_live,
               "nav[aria-label='Main navigation'] a[aria-current=page]",
               "Articles"
             )

      assert has_element?(show_live, ".article-body p", "Current body")
      assert has_element?(show_live, ".article-reading-header a[href='/']", "All articles")

      assert has_element?(
               show_live,
               ".article-reading-meta time[datetime='#{Date.to_iso8601(article.date)}']"
             )
    end
  end
end
