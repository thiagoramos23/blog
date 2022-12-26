defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Article
  alias Blog.Posts.Category

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
end
