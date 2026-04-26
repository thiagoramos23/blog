defmodule Blog.Storage.Adapter do
  @callback upload_post_image(Plug.Upload.t()) :: {:ok, String.t()} | {:error, term()}
end
