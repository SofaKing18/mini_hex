defmodule MiniHex.Repository.Publisher do
  @moduledoc false
  use MiniHex.Storage
  alias MiniHex.Repository

  def publish(state, binary) do
    {:ok, {checksum, metadata, _files}} = :hex_tar.unpack({:binary, binary})
    name = metadata.name
    version = metadata.version
    checksum = List.to_string(checksum)

    dependencies = build_dependencies(metadata.requirements)
    release = %{version: version, checksum: checksum, dependencies: dependencies}
    new_package = %{name: name, releases: [release]}
    
    Storage.write!(Repository.tarball_path(name, version), binary)
    Map.update(state, name, new_package, &add_release(&1, release))
  end

  defp add_release(package, release) do
    true = not release.version in Enum.map(package.releases, & &1.version)
    %{package | releases: package.releases ++ [release]}
  end

  defp build_dependencies(requirements) do
    Enum.map(requirements, fn {package, map} ->
      Map.put(map, :package, package)
    end)
  end

  def retire(state, name, version, reason, message) do
    Map.update!(state, name, &do_retire(&1, version, reason, message))
  end

  defp do_retire(package, version, reason, message) do
    true = version in Enum.map(package.releases, & &1.version)

    releases =
      Enum.map(package.releases, fn release ->
        if release.version == version do
          Map.put(release, :retired, %{reason: reason, message: message})
        else
          release
        end
      end)
    %{package | releases: releases}
  end
end
