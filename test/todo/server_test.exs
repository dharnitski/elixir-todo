defmodule InAction.Todo.ServerTest do
  use ExUnit.Case

  test "Add Entry" do
    {:ok, todo_server} = Todo.Server.start
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
    {:ok, todo_server} = Todo.Server.start
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})
    Todo.Server.delete_entry(todo_server, 2)
    assert Todo.Server.entries(todo_server, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"},
    ]
  end

  test "Update Entry" do
    {:ok, todo_server} = Todo.Server.start
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
    Todo.Server.update_entry(todo_server, %{date: {2013, 12, 20}, id: 1, title: "Movie"})
    assert Todo.Server.entries(todo_server, {2013, 12, 20}) ==
    [
      %{date: {2013, 12, 20}, id: 1, title: "Movie"},
    ]
  end
end
