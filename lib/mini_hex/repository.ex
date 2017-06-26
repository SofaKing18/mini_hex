defmodule MiniHex.Repository.Package do
  defstruct [:name]
end

defmodule MiniHex.Repository do
  alias MiniHex.Repository.Package

  @name __MODULE__

  def start_link() do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def publish(name) do
    Agent.update(@name, &Map.put(&1, name, %Package{name: name}))
  end

  def packages() do
    Agent.get(@name, &Map.values(&1))
  end
end
