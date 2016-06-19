defmodule Todo.PoolSupervisor.Test do
  use ExUnit.Case

  setup do
    {:ok, pid1} = Todo.ProcessRegistry.start_link()
    {:ok, pid2} = Todo.PoolSupervisor.start_link("./persist/", 1)

    on_exit(fn ->
      Process.exit(pid1, :kill)
      Process.exit(pid2, :kill)
      File.rm_rf("./persist/")
    end)

    :ok
  end

  test "Pool Supervisor" do
    Todo.DatabaseWorker.store(1, "key", "data")
    assert Todo.DatabaseWorker.get(1, "key") == "data"
  end

end
