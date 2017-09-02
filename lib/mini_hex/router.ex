defmodule MiniHex.Router do
  use Plug.Router
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
    send_file(conn, 200, path)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
