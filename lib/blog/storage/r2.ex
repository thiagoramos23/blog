defmodule Blog.Storage.R2 do
  @moduledoc false

  @behaviour Blog.Storage.Adapter

  alias ExAws.S3

  @impl true
  def upload_post_image(%Plug.Upload{} = upload) do
    with {:ok, config} <- fetch_config(),
         {:ok, body} <- File.read(upload.path),
         key <- object_key(config.upload_prefix, upload.filename),
         {:ok, _response} <-
           config.bucket
           |> S3.put_object(
             key,
             body,
             content_type: upload.content_type,
             cache_control: "public, max-age=31536000, immutable"
           )
           |> ExAws.request() do
      {:ok, public_url(config.public_url, key)}
    end
  end

  defp fetch_config do
    config = Application.get_env(:blog, __MODULE__, [])

    case {Keyword.get(config, :bucket), Keyword.get(config, :public_url)} do
      {nil, _} ->
        {:error, :missing_bucket}

      {_, nil} ->
        {:error, :missing_public_url}

      {bucket, public_url} ->
        {:ok,
         %{
           bucket: bucket,
           public_url: public_url,
           upload_prefix: Keyword.get(config, :upload_prefix, "posts")
         }}
    end
  end

  defp object_key(prefix, filename) do
    today = Date.utc_today() |> Date.to_iso8601()
    unique = System.unique_integer([:positive])

    [prefix, today, "#{unique}-#{sanitize_filename(filename)}"]
    |> Enum.join("/")
  end

  defp sanitize_filename(filename) do
    filename
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9.\-_]+/u, "-")
    |> String.trim("-")
  end

  defp public_url(base_url, key) do
    String.trim_trailing(base_url, "/") <> "/" <> key
  end
end
