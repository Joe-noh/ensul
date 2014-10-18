defmodule Ensul.DSL do

  [:describe, :context, :facts, :about, :concerning]
  |> Enum.each fn (macro_name) ->
    defmacro unquote(macro_name)(desc, do: block) do
      quote do
        Ensul.StackServer.push(unquote desc)
        unquote(block)
        Ensul.StackServer.pop
      end
    end
  end

  [:it, :fact, :make_sure, :see_if, :verify]
  |> Enum.each fn (macro_name) ->
    defmacro unquote(macro_name)(desc, do: block) do
      quote do
        Ensul.StackServer.push(unquote desc)
        test Ensul.StackServer.cat() do
          unquote(block)
        end
        Ensul.StackServer.pop
      end
    end
  end
end
