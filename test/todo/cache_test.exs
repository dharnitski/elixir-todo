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

  test "Cache to reuse processes" do
    {:ok, _} = Todo.Cache.start_link
    bobs1 = Todo.Cache.server_process("Bob's list")
    #load server in client process
    bobs2 = Todo.Cache.server_process("Bob's list")
    alice1 = Todo.Cache.server_process("Alice's list")
    assert bobs1 == bobs2
    assert bobs1 != alice1
  end

  test "Cache to check Server in todo process" do
    {:ok, _} = Todo.Cache.start_link
    bobs1 = Todo.Cache.server_process("Bob's list")
    #load server in to-do cache process
    bobs2 = GenServer.call(:todo_cache, {:server_process, "Bob's list"})
    assert bobs1 == bobs2
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
