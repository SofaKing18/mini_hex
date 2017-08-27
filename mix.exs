defmodule MiniHex.Mixfile do
  use Mix.Project

  def project do
    [app: :mini_hex,
     version: "0.1.0",
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
      {:hex_tar, path: "../hex_tar"},
      {:hex_registry, path: "../hex_registry"},
    ]
  end
end
