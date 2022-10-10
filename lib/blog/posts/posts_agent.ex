defmodule Blog.Posts.PostsAgent do
  use Agent

  alias Blog.Posts.Article
  alias Blog.Repo

  @files_path "priv/posts/"

  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_all_posts() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def get_post_by_slug(file_slug) do
    Agent.get(__MODULE__, fn state ->
      Enum.find(state, fn item -> item.slug == file_slug end)
    end)
  end

  def save(article) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, article.title, article)
    end)
  end
end
