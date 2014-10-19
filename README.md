# Ensul

## Usage

```elixir
defmodule MyModuleTest do
  use Ensul

  before_all fn ->
    IO.puts "before all"
  end

  after_all fn ->
    IO.puts "after all"
  end

  describe "MyModule" do
    before_each fn ->
      IO.puts "before each"
    end

    after_each fn ->
      IO.puts "after each"
    end

    it "says hello" do
      assert MyModule.hello == "hello"
    end
  end
end
```

### aliases

`describe` : `context`, `facts`, `about`, `concerning` <br>
`it` : `fact`, `make_sure`, `see_if`, `verify`
