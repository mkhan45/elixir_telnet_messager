defmodule Mix.Tasks.StartServer do
  use Mix.Task

  def run(_) do
    Server.accept(4000)
  end
end
