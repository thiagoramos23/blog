defmodule BlogWeb.ArticleLive.Show do
  use BlogWeb, :live_view

  alias Blog.Posts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:about_active, false)
     |> assign(:total_read_time, 0)}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    article = get_article_by_slug(slug)

    {:noreply,
     socket
     |> assign(:article, article)
     |> assign(:page_title, "Thiago Ramos - #{article.title}")
     |> assign(:total_read_time, get_total_read_time(article))}
  end

  defp get_article_by_slug(slug) do
    article = Posts.get_article_by_slug(slug)
    %{article | html_body: Highlighter.highlight(article.html_body)}
  end

  defp get_total_read_time(%{body: body}) do
    total_words = body |> String.split(" ") |> Enum.count()
    div(total_words, 300)
  end
end
