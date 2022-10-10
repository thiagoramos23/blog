defmodule BlogWeb.ArticleLive.Index do
  use BlogWeb, :live_view

  alias Blog.Posts.PostsAgent

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:articles, list_articles())
     |> assign(:page_path, "")}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, assign(socket, :page_path, url)}
  end

  defp list_articles do
    # Blog.Repo.all(Blog.Posts.Article)
    PostsAgent.get_all_posts()
  end
end
