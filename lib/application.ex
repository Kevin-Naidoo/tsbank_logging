defmodule LogProducer.Application do

  #use Application
  def start(_type, _args) do
    children = [
      {Metrics.Telemetry.ReporterState, 0},
      Metrics.Telemetry
    ]

    opts = [strategy: :one_for_one, name: Metrics.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
