defmodule Todo.Server.Test do
  use ExUnit.Case, async: false

  setup do
    cleanup
    Todo.Database.start("./persist/")

    on_exit(fn ->
      cleanup
    end)

    :ok
  end

  defp cleanup do
    case GenServer.whereis(:database_server) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end
    File.rm_rf("./persist/test")
  end

  test "Persistence" do
    {:ok, todo_server1} = Todo.Server.start("test")
    assert [] == Todo.Server.entries(todo_server1, {2013, 12, 20})
    Todo.Server.add_entry(todo_server1, %{date: {2013, 12, 19}, title: "Dentist"})
    {:ok, todo_server2} = Todo.Server.start("test")
    assert Todo.Server.entries(todo_server2, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"}
    ]
  end
end
