defmodule Todo.ProcessRegistry.Map.Test do
  use ExUnit.Case

  setup do
    case GenServer.whereis(:process_registry) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end
  end

  test "Registry Registration" do
    {:ok, _} = Todo.ProcessRegistry.Map.start_link
    :yes = Todo.ProcessRegistry.Map.register_name({:database_worker, 1}, self)
    pid = Todo.ProcessRegistry.Map.whereis_name({:database_worker, 1})
    assert Process.alive?(pid)
  end

  test "Registry Initial State" do
    {:ok, _} = Todo.ProcessRegistry.Map.start_link
    assert :undefined = Todo.ProcessRegistry.Map.whereis_name({:database_worker, 1})
  end

  test "Registry Unregistration" do
    {:ok, _} = Todo.ProcessRegistry.Map.start_link
    :yes = Todo.ProcessRegistry.Map.register_name({:database_worker, 1}, self)
    pid = Todo.ProcessRegistry.Map.whereis_name({:database_worker, 1})
    Todo.ProcessRegistry.Map.unregister_name({:database_worker, 1})
    assert :undefined = Todo.ProcessRegistry.Map.whereis_name({:database_worker, 1})
    assert Process.alive?(pid)
  end

  test "Unregistration of Terminated process" do
    {:ok, _} = Todo.ProcessRegistry.Map.start_link
    {:ok, worker} = GenServer.Mock.start
    :yes = Todo.ProcessRegistry.Map.register_name({:database_worker, 1}, worker)
    pid = Todo.ProcessRegistry.Map.whereis_name({:database_worker, 1})
    assert Process.alive?(pid)
    assert pid == worker
    Process.exit(pid, :kill)
    assert Process.alive?(pid) == false
    # give some time to supervisor to restart worker
    :timer.sleep(100)
    :undefined = Todo.ProcessRegistry.Map.whereis_name({:database_worker, 1})
  end

  test "Double Registration" do
    {:ok, _} = Todo.ProcessRegistry.Map.start_link
    :yes = Todo.ProcessRegistry.Map.register_name({:database_worker, 1}, self)
    :no = Todo.ProcessRegistry.Map.register_name({:database_worker, 1}, self)
    Todo.ProcessRegistry.Map.unregister_name({:database_worker, 1})
  end

end

defmodule GenServer.Mock do
  use GenServer

  def init(_) do
    {:ok, nil}
  end

  #interface functions
  def start do
    GenServer.start(__MODULE__, nil)
  end
end
