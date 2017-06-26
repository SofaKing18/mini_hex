defmodule MiniHex.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias MiniHex.{RegistryBuilder, Repository}

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

    :ok = Repository.publish("foo", "1.0.0", "dummy-checksum", [])

    conn = get("/names")
    assert conn.status == 200
    assert RegistryBuilder.decode_names(conn.resp_body) ==
           %{packages: [%{name: "foo"}]}
  end

  test "/packages/:name" do
    :ok = Repository.publish("foo", "1.0.0", "dummy-checksum", [%{package: "bar", requirement: "~> 1.0"}])
    :ok = Repository.publish("foo", "1.1.0", "dummy-checksum", [])

    conn = get("/packages/foo")
    assert conn.status == 200
    assert RegistryBuilder.decode_package(conn.resp_body) ==
           %{releases: [
             %{version: "1.0.0", checksum: "dummy-checksum", dependencies: [%{package: "bar", requirement: "~> 1.0"}]},
             %{version: "1.1.0", checksum: "dummy-checksum", dependencies: []}]}

    conn = get("/packages/bar")
    assert conn.status == 404
  end

  defp get(path) do
    conn = conn(:get, path)
    MiniHex.Router.call(conn, @opts)
  end
end
