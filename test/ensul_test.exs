defmodule EnsulTest do
  use Ensul

  before_all do
    IO.puts "before all"
  end

  after_all do
    IO.puts "after all"
  end

  describe "Ensul" do
    before_each do
      IO.puts "before each"
    end

    after_each do
      IO.puts "after each"
    end

    it "can write tests like this" do
      assert 1+1 == 2
    end

    fact "behaves like ex_unit" do
      catch_error(raise RuntimeError, "Oops!")
    end
  end
end
