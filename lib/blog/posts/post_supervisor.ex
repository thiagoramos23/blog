defmodule Blog.Posts.PostSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      Blog.Posts.PostsAgent
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
