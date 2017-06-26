defmodule MiniHex.Repository.Package do
  @enforce_keys [:name]
  defstruct [name: nil, releases: []]
end

defmodule MiniHex.Repository.Release do
  @enforce_keys [:version]
  defstruct [version: nil, checksum: "", dependencies: []]
end

defmodule MiniHex.Repository do
  alias MiniHex.Repository.{Package, Release}

  @name __MODULE__

  def start_link() do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def publish(name, version, checksum, dependencies) do
    release = %Release{version: version, checksum: checksum, dependencies: dependencies}
    package = %Package{name: name, releases: [release]}
    Agent.update(@name, &Map.put(&1, name, package))
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
