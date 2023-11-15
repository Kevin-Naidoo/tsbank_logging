defmodule TransferRate do
  alias Metrics.Telemetry.ReporterState

  def tps(module, function, params \\ 1) do
    {uSecs, :ok} = :timer.tc(module, function, [params])

    transactions_per_second = params/(uSecs/1000000)
    IO.puts("#{module}.#{function} => #{transactions_per_second} tps")
  end

  def tps2(module, function) do
    current_value = ReporterState.value()
    {uSecs, :ok} = :timer.tc(module, function,[current_value])

    transactions_per_second =  current_value/(uSecs/1000000)
    IO.puts("#{module}.#{function} => #{transactions_per_second} tps")
  end
end
