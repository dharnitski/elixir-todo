defmodule Todo.Cache.Test do
  use ExUnit.Case, async: false

  test "Cache" do
    {:ok, cache} = Todo.Cache.start
    bobs1 = Todo.Cache.server_process(cache, "Bob's list")
    bobs2 = Todo.Cache.server_process(cache, "Bob's list")
    alice1 = Todo.Cache.server_process(cache, "Alice's list")
    assert bobs1 == bobs2
    assert bobs1 != alice1
  end

  test "Use cache for ToDo list" do
    #clean up state
    cleanup

    {:ok, cache} = Todo.Cache.start
    {:ok, bobs_list} = Todo.Cache.server_process(cache, "Bob's list")
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
