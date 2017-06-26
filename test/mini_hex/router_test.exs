defmodule MiniHex.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts MiniHex.Router.init([])

  test "/names" do
    conn = conn(:get, "/names")
    conn = MiniHex.Router.call(conn, @opts)

    assert conn.status == 200
    assert MiniHex.RegistryBuilder.decode_names(conn.resp_body) ==
           %{packages: [%{name: "foo"}]}
  end
end
