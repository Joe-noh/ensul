defmodule EnsulTest do
  use Ensul

  describe "Ensul" do
    it "can write tests like this" do
      assert 1+1 == 2
    end

    fact "behaves like ex_unit" do
      catch_error(raise RuntimeError, "Oops!")
    end
  end
end
