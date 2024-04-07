defmodule Blog.Metric.ViewMetric do
  use Ecto.Schema
  import Ecto.Changeset

  schema "view_metrics" do
    field :request_path, :string
    field :method, :string
    field :socket_id, :string

    timestamps()
  end

  @doc false
  def changeset(view_metric, attrs) do
    view_metric
    |> cast(attrs, [:request_path, :method, :socket_id])
    |> validate_required([:request_path, :method, :socket_id])
    |> unique_constraint([:socket_id, :request_path, :method])
  end
end
