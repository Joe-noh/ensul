defmodule Ensul.StackServer do
  @moduledoc """
  This module provides a server behave as a stack.
  """

  use GenServer

  @name {:global, __MODULE__}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def push(item) do
    GenServer.cast(@name, {:push, item})
  end

  def pop do
    GenServer.call(@name, :pop)
  end

  def cat do
    GenServer.call(@name, :cat)
  end

  def init, do: []


  # callbacks

  def handle_cast({:push, item}, stack) do
    {:noreply, [item | stack]}
  end

  def handle_call(:pop, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:pop, _from, [head | rest]) do
    {:reply, head, rest}
  end

  def handle_call(:cat, _from, stack) do
    message = stack |> Enum.reverse |> Enum.join(" ")
    {:reply, message, stack}
  end
end
