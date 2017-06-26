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
end
