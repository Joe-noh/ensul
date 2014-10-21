defmodule Ensul.ContextManager do
  use GenServer
  alias __MODULE__, as: CM

  defstruct callback_table: nil, desc_stack: []

  @global_name {:global, CM}
  @types_and_fetch_signs [
    {:before_all,  :fetch_before_all},  {:after_all,  :fetch_after_all},
    {:before_each, :fetch_before_each}, {:after_each, :fetch_after_each}
  ]
  @types_and_set_signs [
    {:before_all,  :set_before_all},  {:after_all,  :set_after_all},
    {:before_each, :set_before_each}, {:after_each, :set_after_each}
  ]

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

  Enum.each @types_and_fetch_signs, fn {callback_type, call_sign} ->
    def fetch_callback(unquote callback_type) do
      GenServer.call(@global_name, unquote(call_sign))
    end
  end

  Enum.each @types_and_set_signs, fn {callback_type, cast_sign} ->
    def set_callback(unquote(callback_type), function) do
      GenServer.cast(@global_name, {unquote(cast_sign), function})
    end
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

  Enum.each @types_and_set_signs, fn {callback_type, cast_sign} ->
    def handle_cast({unquote(cast_sign), function}, state = %CM{callback_table: table}) do
      :ets.insert(table, {{unquote(callback_type), concat_desc(state)}, function})
      {:noreply, state}
    end
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

  Enum.each @types_and_fetch_signs, fn {callback_type, call_sign} ->
    def handle_call(unquote(call_sign), _from, state = %CM{callback_table: table}) do
      case :ets.lookup(table, {unquote(callback_type), concat_desc(state)}) do
        [] -> {:reply, nil, state}
        [{_, callback}] -> {:reply, callback, state}
      end
    end
  end

  # private functions

  defp concat_desc(%CM{desc_stack: stack}) do
    stack |> Enum.reverse |> Enum.join(" ")
  end
end
