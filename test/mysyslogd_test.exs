defmodule MysyslogdTest do
  use ExUnit.Case
  doctest Mysyslogd

  setup do
    Mysyslogd.start_link()
    {:ok, socket} = :gen_udp.open(5500)
  end

  test "send syslog message", %{socket: socket} do
    message = "<34>1 2023-10-01T12:34:56Z mymachine.example.com myapp - - - Hello, syslog!"
    {:ok, _pid, _} = :gen_udp.send(socket, {127, 0, 0, 1}, 5140, message)
    assert_receive {:syslog, ^message}
  end

  test "send multiple syslog messages", %{socket: socket} do
    messages = [
      "<34>1 2023-10-01T12:34:56Z mymachine.example.com myapp - - - First message",
      "<34>1 2023-10-01T12:35:56Z mymachine.example.com myapp - - - Second message",
      "<34>1 2023-10-01T12:36:56Z mymachine.example.com myapp - - - Third message"
    ]

    Enum.each(messages, fn message ->
      {:ok, _pid, _} = :gen_udp.send(socket, {127, 0, 0, 1}, 5140, message)
    end)

    Enum.each(messages, fn message ->
      assert_receive {:syslog, ^message}
    end)
  end
end
