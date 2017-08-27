defmodule MiniHex.Repository.Package do
  @enforce_keys [:name]
  defstruct [name: nil, releases: []]
end

defmodule MiniHex.Repository.Release do
  @enforce_keys [:version, :checksum]
  defstruct [version: nil, checksum: "", dependencies: [], retired: nil]
end

defmodule MiniHex.Repository.RetirementStatus do
  @enforce_keys [:reason]
  defstruct [reason: nil, message: nil]
end

defmodule MiniHex.Repository.Dependency do
  @enforce_keys [:package, :requirement]
  defstruct [package: nil, requirement: "", optional: false, app: nil, repository: nil]
end

defmodule MiniHex.Repository.State do
  @moduledoc false

  def path() do
    data_dir = Application.fetch_env!(:mini_hex, :data_dir)
    Path.join([data_dir, "state.bin"])
  end

  def load() do
    case File.read(path()) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      {:error, :enoent} -> %{}
    end
  end

  def dump(state) do
    File.write!(path(), :erlang.term_to_binary(state))
  end
end

defmodule MiniHex.Repository do
  alias MiniHex.Repository.{Package, Release, RetirementStatus, State}

  @name __MODULE__

  def start_link() do
    File.mkdir_p!(tarballs_dir())
    Agent.start_link(fn -> State.load() end, name: @name)
  end

  def tarballs_dir() do
    data_dir = Application.fetch_env!(:mini_hex, :data_dir)
    Path.join([data_dir, "tarballs"])
  end

  def tarball_path(name, version) do
    Path.join([tarballs_dir(), "#{name}-#{version}.tar"])
  end

  def clear() do
    Agent.update(@name, fn _ -> %{} end)
  end

  def packages() do
    Agent.get(@name, &Map.values(&1))
  end

  def fetch(name) do
    Agent.get(@name, &Map.fetch(&1, name))
  end

  ## Publish

  def publish(binary) when is_binary(binary) do
    {:ok, {checksum, metadata, _files}} = :hex_tar.unpack({:binary, binary})
    name = metadata.name
    version = metadata.version
    checksum = List.to_string(checksum)

    File.write!(tarball_path(name, version), binary)
    dependencies = build_dependencies(metadata.requirements)

    publish(name, version, checksum, dependencies)
  end

  def publish(name, version, checksum, dependencies) do
    release = %Release{version: version, checksum: checksum, dependencies: dependencies}
    new_package = %Package{name: name, releases: [release]}

    Agent.update(@name, fn state ->
      state = Map.update(state, name, new_package, &add_release(&1, release))
      State.dump(state)
      state
    end)
  end

  defp build_dependencies(requirements) do
    Enum.map(requirements, fn {package, map} ->
      Map.put(map, :package, package)
    end)
  end

  defp add_release(package, release) do
    true = not release.version in Enum.map(package.releases, & &1.version)
    %{package | releases: package.releases ++ [release]}
  end

  ## Retire

  def retire(name, version, reason, message) do
    Agent.update(@name, fn state ->
      state = Map.update!(state, name, &do_retire(&1, version, reason, message))
      State.dump(state)
      state
    end)
  end

  defp do_retire(package, version, reason, message) do
    true = version in Enum.map(package.releases, & &1.version)

    releases =
      Enum.map(package.releases, fn release ->
        if release.version == version do
          %{release | retired: %RetirementStatus{reason: reason, message: message}}
        else
          release
        end
      end)
    %{package | releases: releases}
  end
end
