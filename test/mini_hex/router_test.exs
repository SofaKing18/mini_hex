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

    :ok = Repository.publish("foo", "0.1.0", read_fixture("foo-0.1.0/foo-0.1.0.tar"))

    conn = get("/names")
    assert conn.status == 200
    assert RegistryBuilder.decode_names(conn.resp_body) ==
           %{packages: [%{name: "foo"}]}
  end

  test "/versions" do
    :ok = Repository.publish("foo", "0.1.0", read_fixture("foo-0.1.0/foo-0.1.0.tar"))
    :ok = Repository.publish("foo", "0.1.1", read_fixture("foo-0.1.1/foo-0.1.1.tar"))
    :ok = Repository.retire("foo", "0.1.1", :RETIRED_SECURITY, "CVE-000")

    conn = get("/versions")
    assert conn.status == 200
    assert RegistryBuilder.decode_versions(conn.resp_body) ==
           %{packages: [
             %{name: "foo", versions: ["0.1.0", "0.1.1"], retired: [1]}]}
  end

  test "/packages/:name" do
    :ok = Repository.publish("foo", "0.1.0", read_fixture("foo-0.1.0/foo-0.1.0.tar"))
    :ok = Repository.publish("foo", "0.1.1", read_fixture("foo-0.1.1/foo-0.1.1.tar"))
    :ok = Repository.retire("foo", "0.1.1", :RETIRED_SECURITY, "CVE-000")

    checksum1 = "97B31E66E121F22985FD8B356B2FEFE9DA1670A5C526C3E2F39FE04315ABDD64"
    checksum2 = "0E65581EAA7C69CFA092381D9B8A3F7F4A01A3D7682F4099446D457E46D0695F"

    conn = get("/packages/foo")
    assert conn.status == 200
    assert RegistryBuilder.decode_package(conn.resp_body) ==
           %{releases: [
             %{version: "0.1.0", checksum: checksum1, dependencies: []},
             %{version: "0.1.1", checksum: checksum2, dependencies: [], retired: %{message: "CVE-000", reason: :RETIRED_SECURITY}}]}

    conn = get("/packages/bar")
    assert conn.status == 404
  end

  defp get(path) do
    conn = conn(:get, path)
    MiniHex.Router.call(conn, @opts)
  end

  defp read_fixture(path) do
    Path.join(["test", "fixtures", path]) |> File.read!()
  end
end
