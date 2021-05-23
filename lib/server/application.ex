defmodule Server.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Server.TaskSupervisor},
      Server.MessageBuffer,
      Server.ClientStore,
      {Task, fn -> Server.accept(4000) end}
    ]

    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
