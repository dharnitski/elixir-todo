defmodule Todo.Supervisor.Test do
  use ExUnit.Case

  test "Db Worker Recovery" do
    Todo.Supervisor.start_link
    worker = Todo.ProcessRegistry.whereis_name({:database_worker, 2})
    assert Process.alive?(worker)
    Process.exit(worker, :kill)
    assert Process.alive?(worker) == false
    # give some time to superviser to restart worker
    :timer.sleep(100)
    new_worker = Todo.ProcessRegistry.whereis_name({:database_worker, 2})
    assert Process.alive?(new_worker)
    assert worker != new_worker
  end

end
