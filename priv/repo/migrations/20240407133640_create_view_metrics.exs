defmodule Blog.Repo.Migrations.CreateViewMetrics do
  use Ecto.Migration

  def change do
    create table(:view_metrics) do
      add :request_path, :string, null: false
      add :method, :string, null: false
      add :remote_ip, :string, null: false

      timestamps()
    end

    create index(:view_metrics, [:request_path])
    create index(:view_metrics, [:remote_ip])
  end
end
