# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :fluffy_home, FluffyHome.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "9oNoZQcK0JQIWXvEGGZG4WQY4U9X43qSM4yOwRpd3nEsqjp4oJRximpCEyRbLUZf",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: FluffyHome.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :fluffy_home, FluffyHome.InfluxDb,
  hosts:  ["localhost"],
  pool:   [max_overflow: 0, size: 4],
  port:   8086,
  scheme: "http"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
