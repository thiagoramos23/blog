defmodule BlogWeb.AdminUploadControllerTest do
  use BlogWeb.ConnCase, async: true

  setup do
    Application.put_env(:blog, :storage_adapter, Blog.Storage.Test)
    on_exit(fn -> Application.delete_env(:blog, :storage_adapter) end)
    :ok
  end

  setup :register_and_log_in_admin

  test "authenticated admin can upload an editor image", %{conn: conn} do
    upload = %Plug.Upload{
      path: write_temp_file("tiny-test-image"),
      filename: "post-image.png",
      content_type: "image/png"
    }

    conn =
      conn
      |> post("/admin/uploads/images", %{"file" => upload})

    assert %{"url" => url} = json_response(conn, 201)
    assert url == "https://cdn.example.com/posts/post-image.png"
  end

  test "rejects non-image uploads", %{conn: conn} do
    upload = %Plug.Upload{
      path: write_temp_file("plain-text"),
      filename: "notes.txt",
      content_type: "text/plain"
    }

    conn =
      conn
      |> post("/admin/uploads/images", %{"file" => upload})

    assert %{"error" => "invalid_file_type"} = json_response(conn, 422)
  end

  defp write_temp_file(contents) do
    path = Path.join(System.tmp_dir!(), "blog-upload-#{System.unique_integer([:positive])}")
    File.write!(path, contents)
    path
  end
end
