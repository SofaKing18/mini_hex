use Mix.Config

port = (System.get_env("PORT") || "4000") |> String.to_integer()
config :mini_hex, port: port

config :mini_hex, data_dir: "tmp/data"
