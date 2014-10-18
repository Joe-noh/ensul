ExUnit.start()

defmodule TestHelper do

  defmacro macro_to_code(macro) do
    macro |> Macro.expand(__CALLER__) |> Macro.to_string
  end
end
