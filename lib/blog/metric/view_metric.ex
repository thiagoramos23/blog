defmodule Blog.Metric.ViewMetric do
  use Ecto.Schema
  import Ecto.Changeset

  schema "view_metrics" do
    field :request_path, :string
    field :method, :string
    field :remote_ip, :string

    timestamps()
  end

  @doc false
  def changeset(view_metric, attrs) do
    view_metric
    |> cast(attrs, [:request_path, :method, :remote_ip])
    |> validate_required([:request_path, :method, :remote_ip])
  end
end
