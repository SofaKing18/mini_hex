defmodule MiniHex.Router do
  use Plug.Router
  use MiniHex.Storage
  alias MiniHex.Repository

  plug Plug.Logger, log: :debug
  plug :match
  plug :dispatch

  @repo "mini_hex"
  @signature "dummy"

  get "/names" do
    packages = Repository.packages()
    body = :hex_registry.encode_names(@repo, @signature, packages)
    send_resp(conn, 200, body)
  end

  get "/versions" do
    packages = Repository.packages()
    body = :hex_registry.encode_versions(@repo, @signature, packages)
    send_resp(conn, 200, body)
  end

  get "/packages/:name" do
    case Repository.fetch(name) do
      {:ok, package} ->
        body = :hex_registry.encode_package(@repo, @signature, package)
        send_resp(conn, 200, body)
      :error ->
        send_resp(conn, 404, "not found")
    end
  end

  get "/tarballs/:name_version_tar" do
    path = Path.join(Repository.tarballs_dir(), name_version_tar)
    {:ok, binary} = Storage.read(path) 
    conn
    |> put_resp_header(
          "content-disposition",
          ~s[attachment; filename="#{name_version_tar}"]
        )
    |> 
    send_resp(200, binary)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
