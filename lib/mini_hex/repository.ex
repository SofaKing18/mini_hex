defmodule MiniHex.Repository.Package do
  @enforce_keys [:name]
  defstruct [name: nil, releases: []]
end

defmodule MiniHex.Repository.Release do
  @enforce_keys [:version]
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

defmodule MiniHex.Repository do
  alias MiniHex.Repository.{Package, Release, RetirementStatus}
  alias MiniHex.Tar

  @name __MODULE__

  def start_link() do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  @keys ~w(app optional requirement)

  def publish(name, version, binary) when is_binary(binary) do
    data_dir = Application.fetch_env!(:mini_hex, :data_dir)
    File.mkdir_p!(data_dir)
    path = Path.join([data_dir, "#{name}-#{version}.tar"])
    File.write!(path, binary)

    {:ok, files, metadata} = Tar.unpack({:binary, binary}, :mini_hex, name, version)

    dependencies =
      Enum.map(metadata["requirements"], fn list ->
        Enum.into(list, %{}, fn
          {"name", value} ->
            {:package, value}
          {key, value} when key in @keys ->
            {String.to_atom(key), value}
        end)
      end)

    publish(name, version, files['CHECKSUM'], dependencies)
  end

  def publish(name, version, checksum, dependencies) do
    release = %Release{version: version, checksum: checksum, dependencies: dependencies}
    package = %Package{name: name, releases: [release]}

    Agent.update(@name, &Map.update(&1, name, package, fn package -> add_release(package, release) end))
  end

  def retire(name, version, reason, message) do
    Agent.update(@name, &Map.update!(&1, name, fn package -> do_retire(package, version, reason, message) end))
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

  defp add_release(package, release) do
    true = not release.version in Enum.map(package.releases, & &1.version)
    %{package | releases: package.releases ++ [release]}
  end

  def packages() do
    Agent.get(@name, &Map.values(&1))
  end

  def fetch(name) do
    Agent.get(@name, &Map.fetch(&1, name))
  end

  def clear() do
    Agent.update(@name, fn _ -> %{} end)
  end
end
