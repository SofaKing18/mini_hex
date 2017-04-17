defmodule MiniHex.Mixfile do
  use Mix.Project

  def project do
    [app: :mini_hex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     gpb_options: gpb_options(),
     aliases: aliases(),
     compilers: [:gpb] ++ Mix.compilers,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {MiniHex.Application, []}]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.3"},
      {:gpb, "~> 3.23"},
    ]
  end

  defp aliases do
    [
      "compile.gpb": &compile_gpb/1,
    ]
  end

  defp gpb_options do
    [verify: :always,
     strings_as_binaries: true,
     maps: true,
     maps_unset_optional: :omitted,
     report_warnings: true,
     target_erlang_version: 18]
  end

  defp compile_gpb(args) do
    alias Mix.Compilers.Erlang
    {opts, _, _} = OptionParser.parse(args, switches: [force: :boolean])

    project     = Mix.Project.config
    proto_paths = project[:proto_paths] || ["priv/proto"]
    erlc_path   = project[:erlc_paths] |> List.first
    mappings    = Enum.zip(proto_paths, Stream.repeatedly(fn -> erlc_path end))
    options     = project[:gpb_options] || []
    options     = options ++ [o: erlc_path]
    manifest    = Path.join(Mix.Project.manifest_path, ".compile.gpb")

    Erlang.compile(manifest, mappings, :proto, :erl, opts, fn
      input, output ->
        Erlang.ensure_application!(:gpb, input)

        file        = Path.basename(input)
        import_path = input |> Path.relative_to_cwd |> Path.dirname
        options     = options ++ [i: import_path]

        case :gpb_compile.file(Erlang.to_erl_file(file), options) do
          :ok -> {:ok, output}
          {:error, _} -> :error
        end
    end)
  end
end
