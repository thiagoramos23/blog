defmodule BlogWeb.AboutLive.Index do
  use BlogWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
