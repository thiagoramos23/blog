defmodule BlogWeb.ArticleLive.Index do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Metric.StatsServer

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:articles, list_articles())
     |> assign(:page_path, "")
     |> assign(:about_active, false)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    StatsServer.record_metric(%{request_path: url, method: "get", socket_id: socket.id})
    {:noreply, assign(socket, :page_path, url)}
  end

  defp list_articles do
    Posts.list_articles()
  end
end
