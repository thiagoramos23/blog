defmodule Blog.Repo.Migrations.AddSourceToArticles do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :source, :string, null: false, default: "github"
    end

    create index(:articles, [:source])
  end
end
