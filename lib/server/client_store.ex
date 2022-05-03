defmodule Server.ClientStore do
  use GenServer

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:get_clients, _from, clients) do
    {:reply, clients, clients}
  end

  @impl true
  def handle_cast({:add_client, socket, username}, clients) do
    {:noreply, Map.put(clients, socket, username)}
  end

  @impl true
  def handle_cast({:rename_client, from, to_}, clients) do
    inverted = Map.new(clients, fn {key, val} -> {val, key} end)
    sock = inverted |> Map.get(from)
    {:noreply, Map.put(clients, sock, to_)}
  end

  @impl true
  def handle_cast({:delete_client, socket}, clients) do
    {:noreply, Map.delete(clients, socket)}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_client(socket, username) do
    GenServer.cast(__MODULE__, {:add_client, socket, username})
  end

  def delete_client(socket) do
    GenServer.cast(__MODULE__, {:delete_client, socket})
  end

  def rename_client(from, to_) do
    GenServer.cast(__MODULE__, {:rename_client, from, to_})
  end

  def get_clients() do
    GenServer.call(__MODULE__, :get_clients)
  end
end
