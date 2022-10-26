defmodule BlogWeb.ArticleLive.Show do
  use BlogWeb, :live_view

  alias Blog.Posts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    {:noreply,
     socket
     |> assign(:article, get_article_by_slug(slug))}
  end

  defp get_article_by_slug(slug) do
    article = Posts.get_article_by_slug(slug)
    %{article | html_body: Highlighter.highlight(article.html_body)}
  end
end
