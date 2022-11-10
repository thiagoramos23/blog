defmodule BlogWeb.AboutLive.Index do
  use BlogWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_path, "")
     |> assign(:about_active, true)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply,
     socket
     |> assign(:page_path, url)
     |> assign(:about_active, true)}
  end
end
