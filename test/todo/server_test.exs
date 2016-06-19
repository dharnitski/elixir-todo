defmodule Todo.Server.Test do
  use ExUnit.Case, async: false

  setup do
    {:ok, pid1} = Todo.ProcessRegistry.start_link()
    {:ok, pid2} = Todo.Database.start_link("./persist/")

    on_exit(fn ->
      Process.exit(pid1, :kill)
      Process.exit(pid2, :kill)
      File.rm_rf("./persist/")
    end)

    :ok
  end

  test "Persistence" do
    {:ok, todo_server1} = Todo.Server.start_link("test")
    assert [] == Todo.Server.entries(todo_server1, {2013, 12, 20})
    :ok = Todo.Server.add_entry(todo_server1, %{date: {2013, 12, 19}, title: "Dentist"})
    {:todo_server, "test"} = Todo.ProcessRegistry.unregister_name({:todo_server, "test"})
    {:ok, todo_server2} = Todo.Server.start_link("test")
    assert Todo.Server.entries(todo_server2, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"}
    ]
  end
end
