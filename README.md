# MiniHex

A minimal Hex Repository. See: https://github.com/hexpm/specifications/blob/master/endpoints.md#repository

## Usage

    # use unreleased hex code
    cd /path/to/hex
    git fetch
    git checkout wm-dependency-repository
    mix install

    # Start server
    cd /path/to/mini_hex
    iex -S mix

    # Publish package (from iex session)
    :ok = MiniHex.Repository.publish(File.read!("test/fixtures/foo-0.1.0/foo-0.1.0.tar"))

    # Add mini_hex repo
    mix hex.repo add mini_hex http://localhost:4000

    # resolve foo
    cd test/fixtures/bar-0.1.0
    mix deps.get

## License

MIT
