defmodule Blog.Writer.PostWriter do
  use GenServer

  import Ecto.Query

  alias Blog.Posts
  alias Blog.Posts.Article
  alias Blog.Repo

  @url "https://api.github.com/repos/thiagoramos23/second-brain/contents/second_brain/Projects/guides"
  @branch "main"
  @poll_interval_ms 60 * 60 * 1000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, state, {:continue, :get_and_write}}
  end

  def handle_continue(:get_and_write, state) do
    # get_posts_and_upsert()
    schedule_work()
    {:noreply, state}
  end

  def handle_info(:scheduled_work, state) do
    get_posts_and_upsert()
    schedule_work()
    {:noreply, state}
  end

  def get_posts_and_upsert() do
    existing = load_existing_index()
    post_category = Posts.get_category_by_slug("posts")

    @url
    |> do_request()
    |> Enum.reject(&unchanged?(&1, existing))
    |> Enum.map(&get_post(&1, post_category))
    |> upsert_articles()
  end

  defp schedule_work do
    Process.send_after(self(), :scheduled_work, @poll_interval_ms)
  end

  def upsert_articles(new_articles) do
    new_articles
    |> Enum.flat_map(fn new_article ->
      case Repo.get_by(Article, slug: new_article.slug) do
        %Article{source: "admin"} ->
          []

        _article ->
          on_conflict = [
            set: [
              title: new_article.title,
              date: new_article.date,
              body: new_article.body,
              html_body: new_article.html_body,
              summary: new_article.summary,
              hash_id: new_article.hash_id,
              html_url: new_article.html_url,
              author: new_article.author,
              category_id: new_article.category_id,
              source: new_article.source
            ]
          ]

          [Repo.insert(new_article, on_conflict: on_conflict, conflict_target: :slug)]
      end
    end)
  end

  defp load_existing_index() do
    from(a in Article,
      where: a.source == "github",
      select: {a.slug, a.hash_id}
    )
    |> Repo.all()
    |> Map.new(fn {slug, hash} -> {slug, %{hash_id: hash}} end)
  end

  defp unchanged?(%{"name" => name, "sha" => github_sha}, existing) do
    case Map.get(existing, slug_from_name(name)) do
      %{hash_id: ^github_sha} -> true
      _ -> false
    end
  end

  defp slug_from_name(name), do: name |> String.split(".") |> hd()

  defp get_post(
         %{
           "download_url" => donwload_url,
           "html_url" => html_url,
           "sha" => hash_id,
           "name" => name
         },
         post_category
       ) do
    [post_metadata, post_content] =
      donwload_url
      |> do_request()
      |> split_metadata_and_content()

    metadata = post_metadata |> parse_metadata()

    params =
      Map.merge(metadata, %{
        body: post_content,
        html_body: Earmark.as_html!(post_content),
        html_url: html_url,
        hash_id: hash_id,
        date: Date.from_iso8601!(metadata.date),
        category_id: post_category.id,
        source: "github",
        slug: slug_from_name(name)
      })

    Article.new_post(params)
  end

  defp split_metadata_and_content(post_content) do
    String.split(post_content, "delimiter\n")
  end

  defp parse_metadata(metadata) do
    metadata
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn item, acc ->
      [key, value] =
        item
        |> String.split(":")

      Map.put(acc, String.to_atom(key), String.trim(value))
    end)
  end

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
