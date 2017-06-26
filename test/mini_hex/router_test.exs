defmodule MiniHex.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias MiniHex.RegistryBuilder
  alias MiniHex.Repository

  @opts MiniHex.Router.init([])

  setup do
    :ok = Repository.clear()
    :ok
  end

  test "/names" do
    conn = get("/names")
    assert conn.status == 200
    assert RegistryBuilder.decode_names(conn.resp_body) == 
           %{packages: []}

    :ok = Repository.publish("foo")

    conn = get("/names")
    assert conn.status == 200
    assert RegistryBuilder.decode_names(conn.resp_body) ==
           %{packages: [%{name: "foo"}]}
  end

  test "/packages/:name" do
    :ok = Repository.publish("foo")

    conn = get("/packages/foo")
    assert conn.status == 200
    assert RegistryBuilder.decode_package(conn.resp_body) ==
           %{releases: []}

    conn = get("/packages/bar")
    assert conn.status == 404
  end

  defp get(path) do
    conn = conn(:get, path)
    MiniHex.Router.call(conn, @opts)
  end
end
