defmodule Blog.Posts.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :slug, :string
    field :name, :string

    timestamps()
  end

  @required_fields [:name, :slug]

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
