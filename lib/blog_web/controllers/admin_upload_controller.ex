defmodule BlogWeb.AdminUploadController do
  use BlogWeb, :controller

  alias Blog.Storage

  def create(conn, %{"file" => %Plug.Upload{content_type: "image/" <> _} = upload}) do
    case Storage.upload_post_image(upload) do
      {:ok, url} ->
        conn
        |> put_status(:created)
        |> json(%{url: url})

      {:error, :missing_bucket} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "storage_not_configured"})

      {:error, :missing_public_url} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "storage_not_configured"})

      {:error, _reason} ->
        conn
        |> put_status(:bad_gateway)
        |> json(%{error: "upload_failed"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "invalid_file_type"})
  end
end
