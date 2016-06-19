defmodule Todo.Cache.Test do
  use ExUnit.Case

  setup do
    {:ok, pid1} = Todo.ProcessRegistry.start_link()
    {:ok, server_supervisor} = Todo.ServerSupervisor.start_link()
    case GenServer.whereis(:todo_cache) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end

    Todo.Database.start_link("./persist/")

    on_exit(fn ->
      Process.exit(pid1, :kill)
      Process.exit(server_supervisor, :kill)
      File.rm_rf("./persist/")
    end)

    :ok
  end

  test "Cache" do
    {:ok, _} = Todo.Cache.start_link
    bobs1 = Todo.Cache.server_process("Bob's list")
    bobs2 = Todo.Cache.server_process("Bob's list")
    alice1 = Todo.Cache.server_process("Alice's list")
    assert bobs1 == bobs2
    assert bobs1 != alice1
  end

  test "Use cache for ToDo list" do
    {:ok, _} = Todo.Cache.start_link
    bobs_list = Todo.Cache.server_process("Bob's list")
    assert Todo.Server.entries(bobs_list, {2013, 12, 19}) == []
    Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})
    assert Todo.Server.entries(bobs_list, {2013, 12, 19}) ==
      [%{date: {2013, 12, 19}, id: 1, title: "Dentist"}]
  end

end
