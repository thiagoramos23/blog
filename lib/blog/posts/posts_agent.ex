defmodule Blog.Posts.PostsAgent do
  use Agent

  alias Blog.Posts.Article

  @files_path "priv/posts/"

  def start_link(_initial_state) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get_all_posts() do
    Agent.get(__MODULE__, fn state ->
      state
      |> Enum.map(fn item ->
        %Article{
          slug: item.slug,
          title: item.title,
          summary: item.summary,
          date: item.date
        }
      end)
    end)
  end

  def get_post_by_slug(file_slug) do
    Agent.get(__MODULE__, fn state ->
      Enum.find(state, fn item -> item.slug == file_slug end)
    end)
  end

  defp save_all() do
    Agent.update(__MODULE__, fn state -> get_and_update(state, @files_path) end)
  end

  defp get_and_update(state, files_path) do
    files_path
    |> File.ls!()
    |> Enum.map(fn file ->
      article = map_to_article(file)

      case Enum.find(state, fn item -> item.slug == article.slug end) do
        nil ->
          [article | state]

        _ ->
          state
      end
    end)
  end

  defp map_to_article(file) do
    file_contents =
      file
      |> File.read!()
      |> String.split("\n")

    [title, summary] =
      file_contents
      |> Enum.take(2)

    markdown = file_contents |> Enum.drop(2) |> Earmark.as_html!()

    %Article{
      title: title,
      summary: summary,
      body: markdown,
      date: Date.utc_today(),
      slug: slugfy(title)
    }
  end

  defp slugfy(title) do
    title
    |> String.trim()
    |> String.downcase()
    |> String.replace(" ", "-")
  end
end
