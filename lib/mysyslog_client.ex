defmodule MysyslogClient do
  @moduledoc """
  An RFC 3164 compliant syslog client that sends messages to a syslog server.
  """

  @syslog_port 5140

  @spec send_message(any(), any()) :: :ok
  def send_message(socket, message) do
    :ok = :gen_udp.send(socket, {127, 0, 0, 1}, @syslog_port, message)
  end

  @spec test() :: none()
  def test do
    {:ok, socket} = :gen_udp.open(0, [:binary, active: false])
    message = "<34>1 2023-10-01T12:34:56Z mymachine.example.com myapp - - - Hello, syslog!"
    :ok = send_message(socket, message)
  end

  def send_many(num_msgs) do
    for _ <- 1..num_msgs do
      {:ok, socket} = :gen_udp.open(0, [:binary, active: false])
      message = "<34>1 2023-10-01T12:34:56Z mymachine.example.com myapp - - - Hello, syslog!"
      :ok = send_message(socket, message)
    end
  end
end
