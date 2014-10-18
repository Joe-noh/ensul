defmodule Ensul do
  use Application

  alias Ensul.StackServer

  defmacro __using__(_) do
    quote do
      use ExUnit.Case
      import Ensul.DSL
    end
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    ets = :ets.new(:repo, [:set, :public, :named_table, {:read_concurrency, true}])

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Ensul.Worker, [arg1, arg2, arg3])
      worker(StackServer, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ensul.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
