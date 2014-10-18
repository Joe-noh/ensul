defmodule ContextManagerTest do
  use ExUnit.Case

  alias Ensul.ContextManager, as: CM

  test "push and pop description" do
    CM.push_description "A"
    assert CM.pop_description == "A"
  end

  test "push and pop description deeply" do
    CM.push_description "A"
    CM.push_description "B"
    CM.push_description "C"

    assert CM.pop_description == "C"
    assert CM.pop_description == "B"
    assert CM.pop_description == "A"
  end

  test "dump description" do
    CM.push_description "I'm"
    CM.push_description "Your"
    CM.push_description "Father"

    assert CM.dump_description == "I'm Your Father"
  end
end
