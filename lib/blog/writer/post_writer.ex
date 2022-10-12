defmodule Blog.Writer.PostWriter do
  use GenServer

  alias Blog.Posts
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

  def handle_continue(:get_and_write, state) do
    get_posts_and_upsert()
    {:noreply, state}
  end

  def get_posts_and_upsert() do
    articles_recorded = Article.get_articles_order_by(:slug)
    articles_on_github = posts_on_github()

    articles = upsert_articles(articles_recorded, articles_on_github)
    update_in_memory_posts(articles)
  end

  defp upsert_articles(old_articles, new_articles) do
    Enum.zip(old_articles, new_articles)
    |> Enum.map(fn {old_article, new_article} ->
      if old_article.slug == new_article.slug && old_article.hash_id != new_article.hash_id do
        on_conflict = [
          set: [
            body: new_article.body,
            summary: new_article.summary,
            hash_id: new_article.hash_id
          ]
        ]

        Repo.insert(new_article, on_conflict: on_conflict, conflict_target: :slug)
      end

      new_article
    end)
    |> then(&insert_new_articles(&1, new_articles))
  end

  defp insert_new_articles(inserted_articles, github_articles) do
    github_articles
    |> Enum.filter(fn article ->
      result =
        Enum.find(inserted_articles, fn inserted_article ->
          inserted_article.slug == article.slug
        end)

      is_nil(result)
    end)
    |> IO.inspect(label: :inserting)
    |> then(&Repo.insert(&1))
  end

  defp update_in_memory_posts(articles) do
  end

  defp posts_on_github() do
    post_category = Posts.get_category_by_slug("posts")

    do_request(@url)
    |> Enum.map(fn item ->
      item
      |> get_post(post_category)
    end)
    |> Enum.sort_by(& &1.slug, &>=/2)
  end

  defp get_post(
         %{
           "download_url" => donwload_url,
           "html_url" => html_url,
           "sha" => hash_id,
           "name" => name
         },
         post_category
       ) do
    post_metadata_and_content =
      donwload_url
      |> do_request()
      |> split_metadata_and_content()

    metadata = post_metadata_and_content |> hd() |> get_metadata()
    post_content = post_metadata_and_content |> get_content()

    params =
      Map.merge(metadata, %{
        body: post_content,
        html_url: html_url,
        hash_id: hash_id,
        category_id: post_category.id,
        slug: name |> String.split(".") |> hd()
      })

    Article.new_post(params)
  end

  defp split_metadata_and_content(post_content) do
    String.split(post_content, "delimiter\n")
  end

  defp get_metadata(post_content) do
    post_content
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn item, acc ->
      [key, value] =
        item
        |> String.split(":")

      Map.put(acc, String.to_atom(key), String.trim(value))
    end)
  end

  defp get_content(post_content), do: post_content |> Enum.drop(1)

  defp headers() do
    [{"Authorization", "Bearer #{token()}"}, {"Accept", "application/vnd.github+json"}]
  end

  defp token do
    System.get_env("GITHUB_TOKEN")
  end

  defp do_request(url) do
    url
    |> Req.get!(headers: headers(), params: [ref: @branch])
    |> then(& &1.body)
  end
end
