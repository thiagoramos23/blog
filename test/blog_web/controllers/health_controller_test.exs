defmodule BlogWeb.HealthControllerTest do
  use BlogWeb.ConnCase, async: true

  test "GET /up returns ok", %{conn: conn} do
    conn = get(conn, "/up")

    assert response(conn, 200) == "ok"
  end
end
