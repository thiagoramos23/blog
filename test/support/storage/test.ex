defmodule Blog.Storage.Test do
  @moduledoc false

  @behaviour Blog.Storage.Adapter

  @impl true
  def upload_post_image(%Plug.Upload{filename: filename}) do
    {:ok, "https://cdn.example.com/posts/#{filename}"}
  end
end
