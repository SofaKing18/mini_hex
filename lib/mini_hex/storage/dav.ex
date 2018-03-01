defmodule MiniHex.Storage.Dav do
  def write!(path, binary) do
    Catalyst.put("/#{path}", binary)
  end

  def read(path) do
    {:ok, status, content} = Catalyst.get(path)
    case status do
      200 -> {:ok, content}
      _ -> {:error, :enoent}
    end
  end

  def exists?(path) do
    {:ok, status, content} = Catalyst.get(path)
    status == 200
  end

  def mkdir_p!(path) do 
    Catalyst.mkcol_p(path)
  end

  def data_dir do
    "#{Application.get_env(:mini_hex, :data_dir)}"
  end
end
