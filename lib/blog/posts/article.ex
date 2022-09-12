defmodule Blog.Posts.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :body, :string
    field :slug, :string
    field :title, :string
    field :date, :date

    timestamps()
  end

  @required_fields [:title, :slug, :body, :date]

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
