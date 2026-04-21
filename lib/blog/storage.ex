defmodule Blog.Storage do
  @moduledoc false

  alias Blog.Storage.R2

  def upload_post_image(%Plug.Upload{} = upload) do
    storage_adapter().upload_post_image(upload)
  end

  defp storage_adapter do
    Application.get_env(:blog, :storage_adapter, R2)
  end
end
