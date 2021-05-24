defmodule Server do
  require Logger

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")

    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(Server.TaskSupervisor, fn ->
        Logger.info("Connection from #{inspect(client)}")
        clear_term(client)
        write_line("Enter Username: ", client)
        {:ok, username} = :gen_tcp.recv(client, 0)

        username = String.trim(username)
        Server.ClientStore.add_client(client, username)

        refresh_screen(client)
        serve(client)
      end)

    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end

  defp serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, message} ->
        clients = Server.ClientStore.get_clients()

        message = "#{clients[socket]}: #{message}"
        Server.MessageBuffer.add_message(message)

        for {client, _} <- clients, do: refresh_screen(client)

        serve(socket)

      {:error, :closed} ->
        Logger.info("Client Disconnected")
        Server.ClientStore.delete_client(socket)
        IO.inspect(Server.ClientStore.get_clients())
        nil
    end
  end

  defp refresh_screen(socket) do
    messages = Server.MessageBuffer.get_messages() |> Enum.reverse() |> Enum.join()
    out_str = "\u001B[2J" <> messages <> "\n> "
    :gen_tcp.send(socket, out_str)
  end

  defp write_line(line, socket), do: :gen_tcp.send(socket, line)

  defp clear_term(socket), do: :gen_tcp.send(socket, "\u001B[2J")
end
