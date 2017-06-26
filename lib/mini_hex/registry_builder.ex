# Based on https://github.com/hexpm/hexpm/blob/492d21eb2376a3374bf315d693a3820ae9a3a6e9/lib/hexpm/repository/registry_builder.ex
defmodule MiniHex.RegistryBuilder do
  @signature "dummy"

  def build_names(packages) do
    packages = for name <- packages, do: %{name: name}

    %{packages: packages}
    |> :hex_pb_names.encode_msg(:Names)
    |> sign_protobuf()
    |> :zlib.gzip()
  end

  defp sign_protobuf(contents) do
    :hex_pb_signed.encode_msg(%{payload: contents, signature: @signature}, :Signed)
  end
end
