defmodule Blog.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION citext"

    create table(:articles) do
      add :title, :string
      add :slug, :string
      add :body, :citext
      add :date, :date

      timestamps()
    end
  end

  def down do
    execute "DROP EXTENSION citext"
    drop table(:articles)
  end
end
