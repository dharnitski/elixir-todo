defmodule Todo.Database.Test do
  use ExUnit.Case, async: false

  setup do
    {:ok, pid} = Todo.ProcessRegistry.start_link()

    on_exit(fn ->
      Process.exit(pid, :kill)
      File.rm_rf("./persist/")
    end)

    :ok
  end

  test "Persistence" do
    Todo.Database.start_link("./persist")

    data = Todo.Database.get("test_key")
    assert(nil == data, "check initial DB state")

    #add data
    Todo.Database.store("test_key", 1)

    data = Todo.Database.get("test_key")
    assert 1 == data, "read the data from datatabase"
  end

end
