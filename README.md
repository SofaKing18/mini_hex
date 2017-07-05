# MiniHex

A minimal Hex Repository. See: https://github.com/hexpm/specifications/blob/master/endpoints.md#repository

## Usage

    # Start server
    iex -S mix

    # Publish package (from iex session)
    :ok = MiniHex.Repository.publish("foo", "0.1.0", File.read!("test/fixtures/foo-0.1.0/foo-0.1.0.tar"))

    # Add mini_hex repo
    mix hex.repo add mini_hex http://localhost:4000

    # resolve foo
    cd test/fixtures/bar-0.1.0
    mix deps.get

## License

MIT
