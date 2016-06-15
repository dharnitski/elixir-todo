defmodule Todo.Cache.Test do
  use ExUnit.Case, async: false

  setup do
    case GenServer.whereis(:todo_cache) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end
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
    #clean up state
    cleanup

    {:ok, _} = Todo.Cache.start_link
    {:ok, bobs_list} = Todo.Cache.server_process("Bob's list")
    assert Todo.Server.entries(bobs_list, {2013, 12, 19}) == []
    Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})
    assert Todo.Server.entries(bobs_list, {2013, 12, 19}) ==
      [%{date: {2013, 12, 19}, id: 1, title: "Dentist"}]
  end

  defp cleanup do
    case GenServer.whereis(:database_server) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end
    File.rm_rf("./persist/")
  end

end
