defmodule Blog.Metric.StatsServer do
  use GenServer
  require Logger

  alias Blog.Metric.StatsServer
  alias Blog.Metrics

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def record_metric(metadata) do
    GenServer.cast(__MODULE__, {:record_metric, metadata})
  end

  @impl true
  def init(opts) do
    :telemetry.attach(__MODULE__, [:blog, :visit_counter], &StatsServer.handle_event/4, nil)
    {:ok, opts}
  end

  @impl true
  def handle_cast({:record_metric, metadata}, state) do
    :telemetry.execute([:blog, :visit_counter], %{}, metadata)
    {:noreply, state}
  end

  def handle_event([:blog, :visit_counter], _measurements, metadata, _config) do
    Task.Supervisor.start_child(Blog.Metric.ViewMetricSupervisor, fn ->
      Metrics.create_view_metric(metadata)
    end)
  end
end
