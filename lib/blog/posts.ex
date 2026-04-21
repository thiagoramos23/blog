defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Article
  alias Blog.Posts.Category

  @default_author "Thiago Ramos"
  @posts_category_name "Posts"
  @posts_category_slug "posts"

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Article
    |> order_by(desc: :date)
    |> Repo.all()
  end

  def list_articles_for_admin do
    Article
    |> order_by(desc: :updated_at, desc: :date)
    |> Repo.all()
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id)

  @doc """
  Gets a single article by slug.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article_by_slug("craft-some-parts")
      %Article{}

      iex> get_article_by_slug("does-not-exist")
      nil

  """
  def get_article_by_slug(slug), do: Repo.get_by(Article, slug: slug)

  @doc """
  Gets a single category by slug.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category_by_slug("craft-some-parts")
      %Article{}

      iex> get_category_by_slug("does-not-exist")
      nil

  """
  def get_category_by_slug(slug), do: Repo.get_by(Category, slug: slug)

  def create_article(attrs) do
    %Article{}
    |> Article.changeset(admin_article_attrs(attrs))
    |> Repo.insert()
  end

  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(admin_article_attrs(attrs, article))
    |> Repo.update()
  end

  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  def change_article(%Article{} = article, attrs \\ %{}) do
    article
    |> Article.changeset(change_article_attrs(attrs, article))
  end

  def default_author do
    Application.get_env(:blog, :default_post_author, @default_author)
  end

  def plain_text_from_html(html) do
    html
    |> normalize_html()
    |> String.replace(~r/<br\s*\/?>/iu, " ")
    |> String.replace(~r/<\/(p|div|li|h1|h2|h3|h4|h5|h6|blockquote|pre|tr|figcaption)>/iu, " ")
    |> String.replace(~r/<[^>]*>/u, "")
    |> decode_common_entities()
    |> normalize_whitespace()
  end

  defp change_article_attrs(attrs, _article) when attrs in [%{}, []], do: %{}
  defp change_article_attrs(attrs, article), do: admin_article_attrs(attrs, article)

  defp admin_article_attrs(attrs, article \\ nil) do
    title = attr(attrs, :title, article && article.title)
    body_html = normalize_html(attr(attrs, :body_html, article && article.html_body))
    body = plain_text_from_html(body_html)
    slug = slug_from(attr(attrs, :slug, article && article.slug), title)
    summary = summary_from(attr(attrs, :summary, article && article.summary), body)
    author = blank_to_default(attr(attrs, :author, article && article.author), default_author())
    date = attr(attrs, :date, article && article.date) || Date.utc_today()
    category = posts_category!()

    %{
      title: title,
      slug: slug,
      body: body,
      html_body: body_html,
      summary: summary,
      date: date,
      hash_id: (article && article.hash_id) || Ecto.UUID.generate(),
      html_url: "/articles/#{slug}",
      author: author,
      category_id: category.id,
      source: "admin"
    }
  end

  defp posts_category! do
    Repo.get_by(Category, slug: @posts_category_slug) ||
      Repo.insert!(
        Category.changeset(%Category{}, %{name: @posts_category_name, slug: @posts_category_slug})
      )
  end

  defp summary_from(summary, body_text) do
    case blank_to_nil(summary) do
      nil -> String.slice(body_text, 0, 180)
      provided -> provided
    end
  end

  defp slug_from(nil, title), do: slug_from("", title)

  defp slug_from(slug, title) do
    fallback_title = blank_to_nil(title) || ""

    slug
    |> blank_to_default(fallback_title)
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
  end

  defp normalize_html(nil), do: ""
  defp normalize_html(html), do: String.trim(html)

  defp normalize_whitespace(text) do
    text
    |> String.replace(~r/\s+/u, " ")
    |> String.trim()
  end

  defp decode_common_entities(text) do
    text
    |> String.replace("&nbsp;", " ")
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#39;", "'")
  end

  defp blank_to_default(value, default) do
    case blank_to_nil(value) do
      nil -> default
      present -> present
    end
  end

  defp blank_to_nil(nil), do: nil

  defp blank_to_nil(value) when is_binary(value) do
    value
    |> String.trim()
    |> case do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp blank_to_nil(value), do: value

  defp attr(attrs, key, fallback) do
    Map.get(attrs, key) || Map.get(attrs, Atom.to_string(key)) || fallback
  end
end
