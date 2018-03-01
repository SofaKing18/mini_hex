defmodule MiniHex.Storage do
  defmacro __using__(_) do
    case Application.get_env(:mini_hex, :storage) do
      :dav ->
        quote do
          alias MiniHex.Storage.Dav, as: Storage
        end

      _ ->
        quote do
          alias MiniHex.Storage.File, as: Storage
        end
    end
  end

  def worker(storage_type \\ Application.get_env(:mini_hex, :storage)) do
    case storage_type do
      :dav ->
        webdav_conf = Application.get_env(:mini_hex, :wed_dav)
        [Supervisor.Spec.worker(Catalyst, [webdav_conf])]

      _ ->
        []
    end
  end
end
