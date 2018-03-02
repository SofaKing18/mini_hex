defmodule MiniHex.Repository.State do
  @moduledoc false
  use MiniHex.Storage

  def path() do
    Path.join([Storage.data_dir(), "state.bin"])
  end

  def load() do
      case Storage.read(path()) do
        {:ok, data} -> 
          :erlang.binary_to_term(data)
        
        {:error, :enoent} -> %{}
    end
  end

  def dump(state) do
    Storage.write!(path(), :erlang.term_to_binary(state))
  end
end