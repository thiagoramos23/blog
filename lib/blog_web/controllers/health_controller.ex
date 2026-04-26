defmodule BlogWeb.HealthController do
  use BlogWeb, :controller

  def show(conn, _params) do
    text(conn, "ok")
  end
end
