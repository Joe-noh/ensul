defmodule Ensul.DSL do

  [:describe, :context, :facts, :about, :concerning]
  |> Enum.each fn (macro_name) ->
    defmacro unquote(macro_name)(desc, do: block) do
      quote do
        case Ensul.ContextManager.fetch_callback(:before_all) do
          nil -> nil
          callback -> callback.()
        end

        Ensul.ContextManager.push_description(unquote desc)
        unquote(block)
        Ensul.ContextManager.pop_description

        #case Ensul.ContextManager.fetch_callback(:after_all) do
          #  nil -> nil
          #callback -> callback.()
          #end
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

  defmacro before_all(block) do
    quote do
      Ensul.ContextManager.set_callback(:before_all, unquote(block))
    end
  end
end
