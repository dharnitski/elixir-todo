defmodule Todo.ServiceSupervisor.Test do
  use ExUnit.Case

  setup do
    {:ok, server_supervisor} = Todo.ServerSupervisor.start_link()
    {:ok, registry} = Todo.ProcessRegistry.start_link()
    {:ok, pool_supervisor} = Todo.PoolSupervisor.start_link("./persist/", 1)

    on_exit(fn ->
      Process.exit(server_supervisor, :kill)
      Process.exit(registry, :kill)
      Process.exit(pool_supervisor, :kill)
      File.rm_rf("./persist/")
    end)

    :ok
  end

  test "Server Supervisor" do
    {ok, todo_server1} = Supervisor.start_child(:todo_server_supervisor, ["test_key"])
    assert [] == Todo.Server.entries(todo_server1, {2013, 12, 20})
    Todo.Server.add_entry(todo_server1, %{date: {2013, 12, 19}, title: "Dentist"})
    assert Todo.Server.entries(todo_server1, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"}
    ]
  end
end
