defmodule MiniHex.Repository do
  alias MiniHex.Repository.State
  alias MiniHex.Repository.Publisher
  use MiniHex.Storage

  @name __MODULE__

  def start_link() do
    make_tarballs_dir()
    Agent.start_link(fn -> State.load() end, name: @name)
  end

  def make_tarballs_dir() do
    if !Storage.exists?(tarballs_dir()) do
      Storage.mkdir_p!(tarballs_dir())
    end
  end

  def tarballs_dir() do
    Path.join([Storage.data_dir(), "tarballs"])
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

  def publish(binary) when is_binary(binary) do
    Agent.update(@name, fn state ->
      state = Publisher.publish(state, binary)
      State.dump(state)
      state
    end)
  end

  def retire(name, version, reason, message) do
    Agent.update(@name, fn state ->
      state = Publisher.retire(state, name, version, reason, message)
      State.dump(state)
      state
    end)
  end
end
