defmodule Mysyslogd do
  @moduledoc """
  An RFC 3164 compliant syslog server that outputs messages to the screen.
  """
  use GenServer
  require Logger

  @syslog_port 5140

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Logger.info("Syslogd server started on port #{@syslog_port}")
    :gen_udp.open(@syslog_port, [:binary, active: true])
  end

  @impl true
  def handle_info({:udp, socket, ip, port, message}, socket) do
    Logger.info("Received UDP packet from #{inspect(ip)}:#{port}")
    Logger.info("Message: #{message}")
    handle_message(message)
    {:noreply, socket}
  end

  defp handle_message(message) do
    case parse_message(message) do
      {:ok, parsed_message} ->
        Logger.info("Received syslog message: #{parsed_message}")

      {:error, reason} ->
        Logger.error("Failed to parse message: #{reason}")
    end
  end

  defp parse_message(message) do
    # Simplified parsing according to RFC 3164
    case Regex.run(~r/<(\d+)>(.*)/, message) do
      [_, priority, msg] ->
        {:ok, "Priority: #{priority}, Message: #{msg}"}

      _ ->
        {:error, "Invalid message format"}
    end
  end
end
