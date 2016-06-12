defmodule Todo.Server.Mocked.Test do
  use ExUnit.Case, async: false

  setup do
    home = self
    :meck.new(Todo.Database, [:no_link])
    :meck.expect(Todo.Database, :get, fn(_) -> nil end)
    :meck.expect(Todo.Database, :store, fn(_, _) -> send home, :called! end)

    on_exit(fn ->
      :meck.unload(Todo.Database)
    end)

    :ok
  end

  test "Init should load data from db" do
    :meck.expect(Todo.Database, :get, fn(_) ->
      Todo.List.new
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "Dentist"}) end)

    {:ok, todo_server} = Todo.Server.start("get_test")
    assert Todo.Server.entries(todo_server, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"},
    ]
  end

  test "Add Entry should store data in db" do
    {:ok, todo_server} = Todo.Server.start("test")
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})
    assert_receive :called!, 10
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

end
