defmodule DSLTest do
  use ExUnit.Case

  alias Ensul.DSL, as: D
  alias Ensul.ContextManager, as: CM
  require D
  import TestHelper

  test "describe" do
    expanded = macro_to_code(D.describe "it", do: "is")

    assert expanded =~ """
      case(Ensul.ContextManager.fetch_callback(:before_all)) do
        nil ->
          nil
        callback ->
          callback.()
      end
      case(Ensul.ContextManager.fetch_callback(:before_each)) do
        nil ->
          nil
        callback ->
          callback.()
      end
      Ensul.ContextManager.push_description("it")
      "is"
      Ensul.ContextManager.pop_description()
      case(Ensul.ContextManager.fetch_callback(:after_each)) do
        nil ->
          nil
        callback ->
          callback.()
      end
      case(Ensul.ContextManager.fetch_callback(:after_all)) do
        nil ->
          nil
        callback ->
          callback.()
      end
    """
  end

  test "it" do
    expanded = macro_to_code(D.it "behave", do: "like this")

    assert expanded =~ """
      case(Ensul.ContextManager.fetch_callback(:before_each)) do
        nil ->
          nil
        callback ->
          callback.()
      end
      Ensul.ContextManager.push_description("behave")
      test(Ensul.ContextManager.dump_description()) do
        "like this"
      end
      Ensul.ContextManager.pop_description()
      case(Ensul.ContextManager.fetch_callback(:after_each)) do
        nil ->
          nil
        callback ->
          callback.()
      end
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

  test "before_all" do
    CM.reset

    expected1 = fn -> 1+1 end
    D.before_all expected1

    D.describe "something" do
      expected2 = fn -> 2+2 end
      D.before_all expected2

      assert expected2 == CM.fetch_callback(:before_all)
    end

    assert expected1 == CM.fetch_callback(:before_all)
  end

  test "after_all" do
    CM.reset

    expected1 = fn -> 1+1 end
    D.after_all expected1

    D.describe "something" do
      expected2 = fn -> 2+2 end
      D.after_all expected2

      assert expected2 == CM.fetch_callback(:after_all)
    end

    assert expected1 == CM.fetch_callback(:after_all)
  end
end
