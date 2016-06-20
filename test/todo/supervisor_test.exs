Code.require_file "test_helper.exs", __DIR__

defmodule Todo.Supervisor.Test do
  use ExUnit.Case

  setup do
    {:ok, pid} = Todo.Supervisor.start_link

    on_exit(fn ->
        Todo.TestHelper.cleanup_gen_servers
    end)

    {:ok, [pid: pid]}
  end

  test "Db Worker Recovery", context do
    worker = Todo.ProcessRegistry.whereis_name({:database_worker, 2})
    assert Process.alive?(worker)
    registry = Process.whereis(:process_registry)
    assert Process.alive?(registry)
    assert %{active: 2, specs: 2, supervisors: 1, workers: 1} == Supervisor.count_children(context[:pid])

    Process.exit(worker, :kill)
    assert Process.alive?(worker) == false
    # give some time to supervisor to restart worker
    :timer.sleep(100)
    new_worker = Todo.ProcessRegistry.whereis_name({:database_worker, 2})
    assert Process.alive?(new_worker)
    assert worker != new_worker
  end

end
