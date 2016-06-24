defmodule Todo.Supervisor do
  use Supervisor

  def init(_) do
    processes = [
      supervisor(Todo.Database, ["./persist/"]),
      supervisor(Todo.ServerSupervisor, []),
      worker(Todo.Cache, [])
    ]

    # We use a :rest_for_one strategy, thus ensuring that a crash of the
    # process registry takes down the entire system
    supervise(processes, strategy: :rest_for_one)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

end
