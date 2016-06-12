defmodule InAction.Todo.ServerTest do
  use ExUnit.Case, async: false

  setup do
    cleanup
    Todo.Database.start("./persist/")
    #:meck.new(Todo.Database, [:no_link])
    #:meck.expect(Todo.Database, :get, fn(_) -> nil end)
    #:meck.expect(Todo.Database, :store, fn(_, _) -> :ok end)

    on_exit(fn ->
      cleanup
      #:meck.unload(Todo.Database)
    end)

    :ok
  end

  defp cleanup do
    case GenServer.whereis(:database_server) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end
    File.rm_rf("./persist/")
  end

  test "Add Entry" do
    {:ok, todo_server} = Todo.Server.start("test")
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 20}, title: "Shopping"})
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})
    assert Todo.Server.entries(todo_server, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"},
      %{date: {2013, 12, 19}, id: 3, title: "Movies"}
    ]
  end

  test "Delete Entry" do
    {:ok, todo_server} = Todo.Server.start("test")
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})
    Todo.Server.delete_entry(todo_server, 2)
    assert Todo.Server.entries(todo_server, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"},
    ]
  end

  test "Update Entry" do
    {:ok, todo_server} = Todo.Server.start("test")
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
    Todo.Server.update_entry(todo_server, %{date: {2013, 12, 20}, id: 1, title: "Movie"})
    assert Todo.Server.entries(todo_server, {2013, 12, 20}) ==
    [
      %{date: {2013, 12, 20}, id: 1, title: "Movie"},
    ]
  end

  test "Persistence" do
    {:ok, todo_server1} = Todo.Server.start("test")
    Todo.Server.add_entry(todo_server1, %{date: {2013, 12, 19}, title: "Dentist"})
    {:ok, todo_server2} = Todo.Server.start("test")
    assert Todo.Server.entries(todo_server2, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"}
    ]
  end
end
