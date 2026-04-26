defmodule BlogWeb.AdminArticleController do
  use BlogWeb, :controller

  alias Blog.Posts
  alias Blog.Posts.Article

  def index(conn, _params) do
    render(conn, "index.html", articles: Posts.list_articles_for_admin())
  end

  def new(conn, _params) do
    changeset =
      Posts.change_article(%Article{
        author: Posts.default_author(),
        date: Date.utc_today(),
        html_body: ""
      })

    render(conn, "new.html",
      changeset: changeset,
      action: Routes.admin_article_path(conn, :create)
    )
  end

  def create(conn, %{"article" => article_params}) do
    case Posts.create_article(article_params) do
      {:ok, _article} ->
        conn
        |> put_flash(:info, "Article created successfully.")
        |> redirect(to: Routes.admin_article_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("new.html",
          changeset: changeset,
          action: Routes.admin_article_path(conn, :create)
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    article = Posts.get_article!(id)
    changeset = Posts.change_article(article)

    render(conn, "edit.html",
      article: article,
      changeset: changeset,
      action: Routes.admin_article_path(conn, :update, article)
    )
  end

  def update(conn, %{"id" => id, "article" => article_params}) do
    article = Posts.get_article!(id)

    case Posts.update_article(article, article_params) do
      {:ok, _article} ->
        conn
        |> put_flash(:info, "Article updated successfully.")
        |> redirect(to: Routes.admin_article_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("edit.html",
          article: article,
          changeset: changeset,
          action: Routes.admin_article_path(conn, :update, article)
        )
    end
  end
end
