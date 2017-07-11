# Based on https://github.com/hexpm/hexpm/blob/492d21eb2376a3374bf315d693a3820ae9a3a6e9/lib/hexpm/repository/registry_builder.ex
defmodule MiniHex.Registry do
  # TODO: check signature when decoding

  def encode_names(repository, signature, packages) do
    packages = for %{name: name} <- packages, do: %{name: name, repository: repository}
    encode(%{packages: packages}, :hex_pb_names, :Names, signature)
  end

  def decode_names(body) do
    decode(body, :hex_pb_names, :Names)
  end

  def encode_versions(repository, signature, packages) do
    packages =
      for %{name: name, releases: releases} <- packages do
        retired = for {release, index} <- Enum.with_index(releases), release.retired != nil, do: index

        %{
          name: name,
          versions: Enum.map(releases, & &1.version),
          retired: retired,
          repository: repository
        }
      end

    encode(%{packages: packages}, :hex_pb_versions, :Versions, signature)
  end

  def decode_versions(body) do
    decode(body, :hex_pb_versions, :Versions)
  end

  def encode_package(_repository, signature, package) do
    releases =
      Enum.map(package.releases, fn release ->
        release
        |> Map.update!(:checksum, &Base.decode16!/1)
        |> remove_empty_retired()
      end)

    encode(%{releases: releases}, :hex_pb_package, :Package, signature)
  end

  defp remove_empty_retired(%{retired: nil} = release), do: Map.delete(release, :retired)
  defp remove_empty_retired(release), do: release

  def decode_package(body) do
    decode(body, :hex_pb_package, :Package)
  end

  defp encode(payload, module, message, signature) do
    payload
    |> module.encode_msg(message)
    |> sign_protobuf(signature)
    |> :zlib.gzip()
  end

  defp decode(body, module, message) do
    %{payload: payload, signature: _signature} =
      body
      |> :zlib.gunzip()
      |> :hex_pb_signed.decode_msg(:Signed)

    module.decode_msg(payload, message)
  end

  defp sign_protobuf(contents, signature) do
    :hex_pb_signed.encode_msg(%{payload: contents, signature: signature}, :Signed)
  end
end
