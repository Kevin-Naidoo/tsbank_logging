#use Mix.Config
import Config

config :logger, backends: [ExLogger]

config :logger, ExLogger,
  level: :debug,
  producer_node: :"logproducer@localhost",
  sink_node: :"logsink@localhost"
