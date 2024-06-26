defmodule Blog.Posts.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Posts.Article
  alias Blog.Repo

  schema "articles" do
    field :summary, :string
    field :body, :string
    field :html_body, :string
    field :slug, :string
    field :title, :string
    field :author, :string
    field :date, :date
    field :hash_id, :string
    field :html_url, :string
    belongs_to :category, Blog.Posts.Category

    timestamps()
  end

  @required_fields [
    :title,
    :slug,
    :body,
    :date,
    :summary,
    :category_id,
    :hash_id,
    :html_url,
    :author
  ]

  @valid_fields [:html_body] ++ @required_fields

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, @valid_fields)
    |> validate_required(@required_fields)
  end

  def new_post(params) do
    struct!(__MODULE__, params)
  end

  def get_articles() do
    Repo.all(Article)
  end

  def get_articles_order_by(order_key) do
    Repo.all(Article, order_by: [:asc, order_key])
  end
end
