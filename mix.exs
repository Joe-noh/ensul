defmodule Ensul.Mixfile do
  use Mix.Project

  def project do
    [app: :ensul,
     version: "0.1.0",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {Ensul, []}]
  end

  defp deps do
    [
      {:ex_doc,  "~> 0.6", only: :dev},
      {:earmark, "~> 0.1", only: :dev}
    ]
  end
end
