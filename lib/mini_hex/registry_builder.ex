# Based on https://github.com/hexpm/hexpm/blob/492d21eb2376a3374bf315d693a3820ae9a3a6e9/lib/hexpm/repository/registry_builder.ex
defmodule MiniHex.RegistryBuilder do
  @signature "dummy"

  def encode_names(packages) do
    encode(%{packages: packages}, :hex_pb_names, :Names)
  end

  def decode_names(body) do
    decode(body, :hex_pb_names, :Names)
  end

  def encode_package(package) do
    encode(package, :hex_pb_package, :Package)
  end

  def decode_package(body) do
    decode(body, :hex_pb_package, :Package)
  end

  defp encode(payload, module, message) do
    payload
    |> module.encode_msg(message)
    |> sign_protobuf()
    |> :zlib.gzip()
  end

  defp decode(body, module, message) do
    %{payload: payload, signature: _signature} =
      body
      |> :zlib.gunzip()
      |> :hex_pb_signed.decode_msg(:Signed)

    module.decode_msg(payload, message)
  end

  defp sign_protobuf(contents) do
    :hex_pb_signed.encode_msg(%{payload: contents, signature: @signature}, :Signed)
  end
end
