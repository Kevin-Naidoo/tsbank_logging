defmodule ExLogger do

  require :gen_event

  def init(__MODULE__) do
    {:ok, configure([])}
  end

  defp configure(opts) do
    state = %{level: nil, producer_node: nil, sink_node: nil}
    configure(opts, state)
  end


  defp configure(opts, state) do
    env = Application.get_env(:logger, __MODULE__, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, __MODULE__, opts)

    level = Keyword.get(opts, :level)
    producer_node = Keyword.get(opts, :producer_node)
    sink_node = Keyword.get(opts, :sink_node)
    #topic = Keyword.get(opts, :topic)
    #metadata = Keyword.get(opts, :metadata)

    %{state | level: level, producer_node: producer_node, sink_node: sink_node}
  end

  def event_call({:configure, opts}, state) do
    {:ok, {:ok, configure(opts, state), configure(opts, state)}}
  end

#gl - group leader
  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, timestamps, metadata}}, %{level: log_level} = state) do
    if meet_level?(level, log_level) do

      #:erpc.call(:"logsink@localhost", ExLogger, :log_to_sink, [level, msg, timestamps, state])
      log_to_sink(level, msg, timestamps, state, metadata)

    end

    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end


  defp log_to_sink(level, message, timestamp, %{producer_node: producer_node} = _state, metadata) do
    message = flatten_message(message) |> Enum.join("\n")
    timestamp = DateTime.utc_now()
    formatted_string = DateTime.to_string(timestamp)

    log_format = "#{producer_node} #{formatted_string} [#{level}] #{message} #{inspect(metadata)}"

    case :global.whereis_name(:log_sink) do
      :undefined -> undefined_pid()

      _pid -> send(:global.whereis_name(:log_sink), log_format)
    end

  end

  defp flatten_message(msg) do
    case msg do
      [n | body] -> ["#{n}: #{body}"]
      _ -> [msg]
    end
  end

  defp undefined_pid do
    IO.puts("Cannot find Log Sink")
  end
end
