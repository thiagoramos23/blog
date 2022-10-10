defmodule Blog.Writer.PostWriter do
  use GenServer

  alias Blog.Posts.Article
  alias Blog.Posts.PostsAgent
  alias Blog.Repo

  @url "https://api.github.com/repos/thiagoramos23/posts/contents/posts"
  @branch "main"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, state, {:continue, :get_and_write}}
  end

  def handle_continue(:get_and_write, _state) do
    articles =
      Article.get_articles_order_by(:title)
      |> Enum.map(fn article ->
        %{title: article.title, hash_id: article.hash_id, article: article}
      end)

    articles_on_github = posts_on_github()

    upsert_articles(articles, articles_on_github)
  end

  defp upsert_articles(old_articles, new_articles) do
    # Compare each article 
  end

  defp posts_on_github() do
    @branch
    |> get_posts()
    |> Enum.map(fn item ->
      item
      |> get_post(@branch)
    end)
  end

  defp get_posts(branch) do
    @url
    |> Req.get!(headers: headers(), params: [ref: branch])
    |> then(& &1.body)
  end

  defp get_post(content_item, branch) do
    # Get the post from github here"
  end

  defp headers() do
    [{"Authorization", "Bearer #{token()}"}, {"Accept", "application/vnd.github+json"}]
  end

  defp token do
    System.get_env("GITHUB_TOKEN")
  end
end
