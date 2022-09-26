defmodule BlogWeb.ArticleLive.Show do
  use BlogWeb, :live_view

  alias Blog.Posts.PostsAgent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    {:noreply,
     socket
     |> assign(:article, PostsAgent.get_post_by_slug(slug))}
  end
end
