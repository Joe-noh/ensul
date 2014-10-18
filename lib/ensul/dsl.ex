defmodule Ensul.DSL do

  [:describe, :context, :facts, :about, :concerning]
  |> Enum.each fn (macro_name) ->
    defmacro unquote(macro_name)(desc, do: block) do
      quote do
        Ensul.ContextManager.push_description(unquote desc)
        unquote(block)
        Ensul.ContextManager.pop_description
      end
    end
  end

  [:it, :fact, :make_sure, :see_if, :verify]
  |> Enum.each fn (macro_name) ->
    defmacro unquote(macro_name)(desc, do: block) do
      quote do
        Ensul.ContextManager.push_description(unquote desc)
        test Ensul.ContextManager.dump_description() do
          unquote(block)
        end
        Ensul.ContextManager.pop_description
      end
    end
  end
end
