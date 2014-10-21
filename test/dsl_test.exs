defmodule DSLTest do
  use ExUnit.Case

  use Ensul
  alias Ensul.ContextManager, as: CM

  import TestHelper

  test "describe" do
    expanded = macro_to_code(describe "it", do: "is")

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
    expanded = macro_to_code(it "behave", do: "like this")

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
    expanded = macro_to_code(describe "it", do: "is")

    assert expanded == macro_to_code(context    "it", do: "is")
    assert expanded == macro_to_code(facts      "it", do: "is")
    assert expanded == macro_to_code(about      "it", do: "is")
    assert expanded == macro_to_code(concerning "it", do: "is")
  end

  test "aliases of it" do
    expanded = macro_to_code(it "is", do: "that")

    assert expanded == macro_to_code(fact      "is", do: "that")
    assert expanded == macro_to_code(make_sure "is", do: "that")
    assert expanded == macro_to_code(see_if    "is", do: "that")
    assert expanded == macro_to_code(verify    "is", do: "that")
  end

  test "before_all" do
    CM.reset

    before_all do: 1

    describe "something" do
      before_all do: 2
      assert CM.fetch_callback(:before_all).() == 2
    end

    assert CM.fetch_callback(:before_all).() == 1
  end

  test "after_all" do
    CM.reset

    after_all do: 1

    describe "something" do
      after_all do: 2
      assert CM.fetch_callback(:after_all).() == 2
    end

    assert CM.fetch_callback(:after_all).() == 1
  end
end
