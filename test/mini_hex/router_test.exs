defmodule MiniHex.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias MiniHex.RegistryBuilder
  alias MiniHex.Repository

  @opts MiniHex.Router.init([])

  test "/names" do
    :ok = Repository.publish("foo")

    conn = conn(:get, "/names")
    conn = MiniHex.Router.call(conn, @opts)
    assert conn.status == 200
    assert RegistryBuilder.decode_names(conn.resp_body) ==
           %{packages: [%{name: "foo"}]}
  end

  test "/packages/:name" do
    :ok = Repository.publish("foo")

    conn = conn(:get, "/packages/foo")
    conn = MiniHex.Router.call(conn, @opts)
    assert conn.status == 200
    assert RegistryBuilder.decode_package(conn.resp_body) ==
           %{releases: []}

    conn = conn(:get, "/packages/bar")
    conn = MiniHex.Router.call(conn, @opts)
    assert conn.status == 404
  end
end
