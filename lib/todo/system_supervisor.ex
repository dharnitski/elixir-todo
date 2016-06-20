defmodule Todo.SystemSupervisor do
  use Supervisor

 @moduledoc "Starts the to-do system. Assumes that process registry is already started and working."

  def init(_) do
    processes = [
      supervisor(Todo.Database, ["./persist/"]),
      supervisor(Todo.ServerSupervisor, []),
      worker(Todo.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

end
