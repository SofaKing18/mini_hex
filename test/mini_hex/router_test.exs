defmodule MiniHex.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts MiniHex.Router.init([])

  test "/" do
    conn = conn(:get, "/")
    conn = MiniHex.Router.call(conn, @opts)

    assert conn.status == 200
    assert conn.resp_body == "hello"
  end
end
