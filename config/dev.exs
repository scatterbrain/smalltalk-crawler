use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :smalltalk_crawler, SmalltalkCrawler.Endpoint,
  http: [port: 4002],
  debug_errors: false,
  code_reloader: false,
  cache_static_lookup: false,
  check_origin: false

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :smalltalk_crawler, SmalltalkCrawler.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "",
  password: "",
  database: "",
  hostname: "",
  pool_size: 10

  #config :eredis, 
  #hostname: "smalltalkcache-dev.qlo03b.0001.use1.cache.amazonaws.com"

config :hedwig,
  clients: [
    %{
      jid: "",
      password: "",
      nickname: "",
      resource: "",
      config: %{ # This is only necessary if you need to override the defaults.
        server: "dockerhost",
        port: 5222, 
        require_tls?: false,
        use_compression?: false,
        use_stream_management?: false,
        transport: :tcp
      }
      #,
      #rooms: [
      #    "lobby@conference.capulet.lit"
      #]
    }
  ]

