defmodule Todo.ProcessRegistry.Test do
  use ExUnit.Case

  setup do
    case GenServer.whereis(:process_registry) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end
  end

  test "Registry Registration" do
    {:ok, _} = Todo.ProcessRegistry.start_link
    :yes = Todo.ProcessRegistry.register_name({:database_worker, 1}, self)
    pid = Todo.ProcessRegistry.whereis_name({:database_worker, 1})
    assert Process.alive?(pid)
  end

  test "Registry Initial State" do
    {:ok, _} = Todo.ProcessRegistry.start_link
    assert :undefined = Todo.ProcessRegistry.whereis_name({:database_worker, 1})
  end

  test "Registry Unregistration" do
    {:ok, _} = Todo.ProcessRegistry.start_link
    :yes = Todo.ProcessRegistry.register_name({:database_worker, 1}, self)
    pid = Todo.ProcessRegistry.whereis_name({:database_worker, 1})
    Todo.ProcessRegistry.unregister_name({:database_worker, 1})
    assert :undefined = Todo.ProcessRegistry.whereis_name({:database_worker, 1})
    assert Process.alive?(pid)
  end

  test "Double Registration" do
    {:ok, _} = Todo.ProcessRegistry.start_link
    :yes = Todo.ProcessRegistry.register_name({:database_worker, 1}, self)
    :no = Todo.ProcessRegistry.register_name({:database_worker, 1}, self)
    Todo.ProcessRegistry.unregister_name({:database_worker, 1})
  end

end
