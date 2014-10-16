defmodule StackServerTest do
  use ExUnit.Case

  alias Ensul.StackServer, as: S

  test "push and pop" do
    S.push 3
    assert S.pop == 3
  end

  test "push and pop deeply" do
    S.push 3
    S.push 2
    S.push 1

    assert S.pop == 1
    assert S.pop == 2
    assert S.pop == 3
  end

  test "cat" do
    S.push "I'm"
    S.push "Your"
    S.push "Father"

    assert S.cat == "I'm Your Father"
  end
end
