defmodule MiniHex.Storage.File do
  alias MiniHex.Storage.File, as: SF
  def write!(path, content) do
    File.write!(path, content)
  end

  def read(path) do
    File.read(path)
  end

  def mkdir_p!(path) do
    File.mkdir_p! path
  end

  def exists?(path) do
    File.exists?(path)
  end
    
  def data_dir() do
    Application.get_env(:mini_hex, :data_dir)
  end
end