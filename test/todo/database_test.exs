defmodule Todo.Database.Test do
  use ExUnit.Case, async: false

  test "Persistence" do
    cleanup
    Todo.Database.start("./test_persist")

    data = Todo.Database.get("test_key")
    assert(nil == data, "check initial DB state")

    #add data
    Todo.Database.store("test_key", 1)

    data = Todo.Database.get("test_key")
    assert 1 == data, "read the data from datatabase"

    #cleanup
    cleanup
  end

  defp cleanup do
    case GenServer.whereis(:database_server) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end
    File.rm_rf("./test_persist/")
  end

end
