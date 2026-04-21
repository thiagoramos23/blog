defmodule BlogWeb.ArticleLiveTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest
  import Blog.PostsFixtures

  defp create_article(_) do
    article = article_fixture(%{title: "Current Article", body_html: "<p>Current body</p>"})
    %{article: article}
  end

  describe "Index" do
    setup [:create_article]

    test "lists published articles", %{conn: conn, article: article} do
      {:ok, _index_live, html} = live(conn, "/")

      assert html =~ "Writing on software"
      assert html =~ article.title
      assert html =~ article.summary
    end
  end

  describe "Show" do
    setup [:create_article]

    test "displays article content", %{conn: conn, article: article} do
      {:ok, _show_live, html} = live(conn, "/articles/#{article.slug}")

      assert html =~ article.title
      assert html =~ "minutes to read"
      assert html =~ "Current body"
    end
  end
end
