defmodule MiniHex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    port = Application.fetch_env!(:mini_hex, :port)
    children = [
      worker(MiniHex.Repository, []),
      Plug.Adapters.Cowboy.child_spec(:http, MiniHex.Router, [], [port: port])
    ]

    opts = [strategy: :one_for_one, name: MiniHex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
