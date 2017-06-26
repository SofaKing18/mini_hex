defmodule MiniHex.Router do
  use Plug.Router

  alias MiniHex.Repository
  alias MiniHex.RegistryBuilder

  plug Plug.Logger, log: :debug
  plug :match
  plug :dispatch

  get "/names" do
    packages = Repository.packages()
    body = RegistryBuilder.encode_names(packages)
    send_resp(conn, 200, body)
  end

  get "/versions" do
    packages = Repository.packages()
    body = RegistryBuilder.encode_versions(packages)
    send_resp(conn, 200, body)
  end

  get "/packages/:name" do
    case Repository.fetch(name) do
      {:ok, package} ->
        body = RegistryBuilder.encode_package(package)
        send_resp(conn, 200, body)
      :error ->
        send_resp(conn, 404, "not found")
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
