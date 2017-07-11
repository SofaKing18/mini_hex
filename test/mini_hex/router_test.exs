defmodule MiniHex.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias MiniHex.{Registry, Repository}

  @opts MiniHex.Router.init([])

  setup do
    :ok = Repository.clear()
    :ok
  end

  test "/names" do
    conn = get("/names")
    assert conn.status == 200
    assert Registry.decode_names(conn.resp_body) == 
           %{packages: []}

    :ok = Repository.publish(read_fixture("foo-0.1.0/foo-0.1.0.tar"))

    conn = get("/names")
    assert conn.status == 200
    assert Registry.decode_names(conn.resp_body) ==
           %{packages: [%{name: "foo", repository: "mini_hex"}]}
  end

  test "/versions" do
    :ok = Repository.publish(read_fixture("foo-0.1.0/foo-0.1.0.tar"))
    :ok = Repository.publish(read_fixture("foo-0.1.1/foo-0.1.1.tar"))
    :ok = Repository.retire("foo", "0.1.1", :RETIRED_SECURITY, "CVE-000")

    conn = get("/versions")
    assert conn.status == 200
    assert Registry.decode_versions(conn.resp_body) ==
           %{packages: [
             %{name: "foo", versions: ["0.1.0", "0.1.1"], retired: [1], repository: "mini_hex"}]}
  end

  test "/packages/:name" do
    :ok = Repository.publish(read_fixture("foo-0.1.0/foo-0.1.0.tar"))
    :ok = Repository.publish(read_fixture("foo-0.1.1/foo-0.1.1.tar"))
    :ok = Repository.retire("foo", "0.1.1", :RETIRED_SECURITY, "CVE-000")

    checksum1 = Base.decode16!("97B31E66E121F22985FD8B356B2FEFE9DA1670A5C526C3E2F39FE04315ABDD64")
    checksum2 = Base.decode16!("0E65581EAA7C69CFA092381D9B8A3F7F4A01A3D7682F4099446D457E46D0695F")

    conn = get("/packages/foo")
    assert conn.status == 200
    assert Registry.decode_package(conn.resp_body) ==
           %{releases: [
             %{version: "0.1.0", checksum: checksum1, dependencies: []},
             %{version: "0.1.1", checksum: checksum2, dependencies: [], retired: %{message: "CVE-000", reason: :RETIRED_SECURITY}}]}

    conn = get("/packages/bar")
    assert conn.status == 404
  end

  test "/packages/:name with dependencies" do
    :ok = Repository.publish(read_fixture("foo-0.1.0/foo-0.1.0.tar"))
    :ok = Repository.publish(read_fixture("bar-0.1.0/bar-0.1.0.tar"))
    checksum = Base.decode16!("94F42470FA277089D11547597E4A7D05D3A4A98F42EDBBF851A822A09EA511FE")

    conn = get("/packages/bar")
    assert conn.status == 200
    assert Registry.decode_package(conn.resp_body) ==
           %{releases: [
             %{version: "0.1.0", checksum: checksum, dependencies: [
               %{app: "foo", optional: false, package: "foo", requirement: "~> 0.1", repository: "mini_hex"}]}]}
  end

  test "/tarballs/:name_version.tar" do
    :ok = Repository.publish(read_fixture("foo-0.1.0/foo-0.1.0.tar"))

    conn = get("/tarballs/foo-0.1.0.tar")
    assert conn.status == 200
    assert conn.resp_body == read_fixture("foo-0.1.0/foo-0.1.0.tar")
  end

  defp get(path) do
    conn = conn(:get, path)
    MiniHex.Router.call(conn, @opts)
  end

  defp read_fixture(path) do
    Path.join(["test", "fixtures", path]) |> File.read!()
  end
end
