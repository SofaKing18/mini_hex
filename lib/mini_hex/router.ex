defmodule MiniHex.Router do
  use Plug.Router

  alias MiniHex.RegistryBuilder

  plug Plug.Logger, log: :debug
  plug :match
  plug :dispatch

  get "/names" do
    packages = ["foo"]
    payload = RegistryBuilder.build_names(packages)
    send_resp(conn, 200, payload)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
