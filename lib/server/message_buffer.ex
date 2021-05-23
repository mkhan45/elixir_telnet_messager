defmodule Server.MessageBuffer do
  use GenServer

  @impl true
  def init(:ok) do
    {:ok, %{messages: []}}
  end

  @impl true
  def handle_call(:get_messages, _from, %{messages: messages} = state) do
    {:reply, messages, state}
  end

  @impl true
  def handle_cast({:add_message, message}, %{messages: messages}) do
    {:noreply, %{messages: [message | messages]}}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_message(message) do
    GenServer.cast(__MODULE__, {:add_message, message})
  end

  def get_messages() do
    GenServer.call(__MODULE__, :get_messages)
  end
end
