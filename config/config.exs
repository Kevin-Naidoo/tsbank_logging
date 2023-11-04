#use Mix.Config
import Config

config :logger, backends: [ExLogger]

config :logger, :console,
  format: "$time [$level] $message $metadata\n",
  metadata: :all,
  metadata_filter: [:time]

config :logger, ExLogger,
  level: :debug,
  sink_node: :"logsink@localhost",
  format: "$time [$level] $message $metadata\n"
