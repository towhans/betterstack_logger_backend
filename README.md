# BetterstackLogger

An Elixir Logger backend for [Betterstack](https://betterstack.com/logs).

# Configuration

You will need a Betterstack source **source_id** which you can copy from your dashboard after you create a one.

```elixir
config :logger,
  level: :info, # or other Logger level
  backends: [BetterstackLogger.HttpBackend]

config :betterstack_logger_backend,
  url: "https://in.logs.betterstack.com", # https://in.logs.bettersack.com is configured by default and you can set your own url
  level: :info, # Default BetterstackLogger level is :info. Note that log messages are filtered by the :logger application first
  source_id: "...", # the Betterstack source UUID, found  on your Betterstack dashboard
  flush_interval: 1_000, # minimum time in ms before a log batch is sent
  max_batch_size: 50, # maximum number of events before a log batch is sent
  metadata: :all # optionally you can drop keys if they exist with `metadata: [drop: [:list, :keys, :to, :drop]]`
```

Alternatively, you can configure these options in your system environment. Prefix the above option names with `BETTERSTACK_`.

```bash
export BETTERSTACK_URL="https://in.logs.betterstack.com"
export BETTERSTACK_API_KEY="..."
export BETTERSTACK_SOURCE_ID="..."
```

## Usage

After configuring BetterstackLogger in `config.exs`, use `Logger.info, Logger.error, ...` functions to send log events to Betterstack app.

## Usage with context

`BetterstackLogger.context` function signatures follows the one of `Logger.metadata` with slight modifications to parameters and return values.

```elixir
# Merges map or keyword with existing context, will overwrite values.
BetterstackLogger.context(%{user: %{id: 3735928559}})
BetterstackLogger.context(user: %{id: 3735928559})

# Get all context entries or a value for a specific key
BetterstackLogger.context(:user)
BetterstackLogger.context()

# Deletes all context entries or specific context key/value
BetterstackLogger.context(user: nil)
BetterstackLogger.reset_context()
```

## Current limitations

Betterstack log event BigQuery table schema is auto-generated per source. If you send a log with `Logger.info("first", user: %{id: 1})`, Betterstack will generate a metadata field of type integer. If in the future, you'll send a log event to the same source using `Logger.info("first", user: %{id: "d9c2feff-d38a-4671-8de4-a1e7f7dd7e3c"1})`, the log with a binary id will be rejected.

BetterstackLogger log payloads sent to Betterstack API are encoded using MsgPack

At this moment BetterstackLogger doesn't support full one-to-one logging of Elixir types and applies the following conversions:

- atoms converted to strings
- charlists are converted to strings
- tuples converted to arrays
- keyword lists converted to maps
- structs converted to maps
- NaiveDateTime and DateTime are converted using the `String.Chars` protocol
- pids are converted to strings

BetterstackLogger doesn't support:

- non-binary messages, e.g. `Logger.info(%{user_count: 1337})`

## Exceptions

BetterstackLogger automatically logs all exceptions and formats stacktraces.

## Troubleshooting

Run `mix betterstack_logger.verify_config` to test your config.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `betterstack_logger_backend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:betterstack_logger_backend, "~> 0.11.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/betterstack_logger_backend](https://hexdocs.pm/betterstack_logger_backend).
