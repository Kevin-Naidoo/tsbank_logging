defmodule Metrics do
  def count do
    :telemetry.execute([:metrics, :count], %{})
  end
end
