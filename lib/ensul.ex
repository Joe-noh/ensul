defmodule Ensul do
  use Application

  defmacro __using__(_) do
    quote do
      use ExUnit.Case
      import Ensul.DSL
    end
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    ets_config = [:set, :public, :named_table, {:read_concurrency, true}]
    ets = :ets.new(ets_name, ets_config)

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Ensul.Worker, [arg1, arg2, arg3])
      worker(Ensul.ContextManager, [ets_name])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ensul.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def ets_name, do: :callback_repository
end
