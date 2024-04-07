defmodule Blog.Metrics do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Metric.ViewMetric

  @doc """
  Creates a new view metric

  ## Examples

      iex> create_view_metric()
      [%ViewMetric{}, ...]

  """
  def create_view_metric(attrs) do
    %ViewMetric{}
    |> ViewMetric.changeset(attrs)
    |> Repo.insert()
  end

  def get_total_visits_by_request_path(url) do
    query =
      from view_metrics in ViewMetric,
        where: view_metrics.request_path == ^url

    Repo.aggregate(query, :count)
  end
end
