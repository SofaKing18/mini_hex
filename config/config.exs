use Mix.Config

port = (System.get_env("PORT") || "4000") |> String.to_integer()
config :mini_hex, :port, port
