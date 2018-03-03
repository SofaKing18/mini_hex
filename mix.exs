defmodule MiniHex.Mixfile do
  use Mix.Project

  def project do
    [app: :mini_hex,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {MiniHex.Application, []}]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.3"},
      {:gpb, "~> 3.23"},
      {:hex_tar, github: "wojtekmach/hex_tar"},
      {:hex_registry, github: "wojtekmach/hex_registry"},
      {:catalyst, "~> 0.2.1"}
    ]
  end
end
