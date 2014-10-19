defmodule Ensul.ContextManager do
  use GenServer
  alias __MODULE__, as: CM

  defstruct callback_table: nil, desc_stack: []

  @global_name {:global, CM}

  def start_link(ets_table_name) do
    GenServer.start_link(CM, [ets_table_name], name: @global_name)
  end

  def push_description(item) do
    GenServer.cast(@global_name, {:push_desc, item})
  end

  def pop_description do
    GenServer.call(@global_name, :pop_desc)
  end

  def dump_description do
    GenServer.call(@global_name, :dump_desc)
  end

  def fetch_callback(:before_all) do
    GenServer.call(@global_name, :fetch_ba)
  end

  def fetch_callback(:after_all) do
    GenServer.call(@global_name, :fetch_aa)
  end

  def fetch_callback(:before_each) do
    GenServer.call(@global_name, :fetch_be)
  end

  def fetch_callback(:after_each) do
    GenServer.call(@global_name, :fetch_ae)
  end

  def set_callback(:before_all, function) do
    GenServer.cast(@global_name, {:set_ba, function})
  end

  def set_callback(:after_all, function) do
    GenServer.cast(@global_name, {:set_aa, function})
  end

  def set_callback(:before_each, function) do
    GenServer.cast(@global_name, {:set_be, function})
  end

  def set_callback(:after_each, function) do
    GenServer.cast(@global_name, {:set_ae, function})
  end

  def reset do
    GenServer.cast(@global_name, :reset)
  end

  # GenServer callback functions

  def init([table_name]) do
    {:ok, %__MODULE__{callback_table: table_name}}
  end

  def handle_cast({:push_desc, item}, state = %CM{desc_stack: stack}) do
    {:noreply, %CM{state | desc_stack: [item | stack]}}
  end

  def handle_cast({:set_ba, function}, state = %CM{callback_table: table}) do
    key = {:before_all, concat_desc(state)}
    :ets.insert(table, {key, function})
    {:noreply, state}
  end

  def handle_cast({:set_aa, function}, state = %CM{callback_table: table}) do
    key = {:after_all, concat_desc(state)}
    :ets.insert(table, {key, function})
    {:noreply, state}
  end

  def handle_cast({:set_be, function}, state = %CM{callback_table: table}) do
    key = {:before_each, concat_desc(state)}
    :ets.insert(table, {key, function})
    {:noreply, state}
  end

  def handle_cast({:set_ae, function}, state = %CM{callback_table: table}) do
    key = {:after_each, concat_desc(state)}
    :ets.insert(table, {key, function})
    {:noreply, state}
  end

  def handle_cast(:reset, state = %CM{callback_table: table}) do
    :ets.delete_all_objects(table)
    {:noreply, %CM{state | desc_stack: []}}
  end

  def handle_call(:pop_desc, _from, state = %CM{desc_stack: []}) do
    {:reply, nil, state}
  end

  def handle_call(:pop_desc, _from, state = %CM{desc_stack: [head | rest]}) do
    {:reply, head, %CM{state | desc_stack: rest}}
  end

  def handle_call(:dump_desc, _from, state) do
    {:reply, concat_desc(state), state}
  end

  def handle_call(:fetch_ba, _from, state = %CM{callback_table: table}) do
    case :ets.lookup(table, {:before_all, concat_desc(state)}) do
      [] -> {:reply, nil, state}
      [{_, callback}] -> {:reply, callback, state}
    end
  end

  def handle_call(:fetch_aa, _from, state = %CM{callback_table: table}) do
    case :ets.lookup(table, {:after_all, concat_desc(state)}) do
      [] -> {:reply, nil, state}
      [{_, callback}] -> {:reply, callback, state}
    end
  end

  def handle_call(:fetch_be, _from, state = %CM{callback_table: table}) do
    case :ets.lookup(table, {:before_each, concat_desc(state)}) do
      [] -> {:reply, nil, state}
      [{_, callback}] -> {:reply, callback, state}
    end
  end

  def handle_call(:fetch_ae, _from, state = %CM{callback_table: table}) do
    case :ets.lookup(table, {:after_each, concat_desc(state)}) do
      [] -> {:reply, nil, state}
      [{_, callback}] -> {:reply, callback, state}
    end
  end

  # private functions

  defp concat_desc(%CM{desc_stack: stack}) do
    stack |> Enum.reverse |> Enum.join(" ")
  end
end
