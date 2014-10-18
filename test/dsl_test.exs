defmodule DSLTest do
  use ExUnit.Case

  alias Ensul.DSL, as: D
  require D
  import TestHelper

  test "describe" do
    expanded = macro_to_code(D.describe "something", do: "hey")

    assert expanded =~ """
      Ensul.StackServer.push("something")
      "hey"
      Ensul.StackServer.pop()
    """
  end

  test "it" do
    expanded = macro_to_code(D.it "behave", do: "like this")

    assert expanded =~ """
      Ensul.StackServer.push("behave")
      test(Ensul.StackServer.cat()) do
        "like this"
      end
      Ensul.StackServer.pop()
    """
  end

  test "aliases of describe" do
    expanded = macro_to_code(D.describe "it", do: "is")

    assert expanded == macro_to_code(D.context    "it", do: "is")
    assert expanded == macro_to_code(D.facts      "it", do: "is")
    assert expanded == macro_to_code(D.about      "it", do: "is")
    assert expanded == macro_to_code(D.concerning "it", do: "is")
  end

  test "aliases of it" do
    expanded = macro_to_code(D.it "is", do: "that")

    assert expanded == macro_to_code(D.fact      "is", do: "that")
    assert expanded == macro_to_code(D.make_sure "is", do: "that")
    assert expanded == macro_to_code(D.see_if    "is", do: "that")
    assert expanded == macro_to_code(D.verify    "is", do: "that")
  end
end
