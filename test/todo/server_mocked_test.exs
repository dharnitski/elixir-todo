defmodule Todo.Server.Mocked.Test do
  use ExUnit.Case, async: false

  setup do
    home = self
    :meck.new(Todo.Database, [:no_link])
    :meck.expect(Todo.Database, :get, fn(_) ->
      Todo.List.new
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "Dentist"}) end)
    :meck.expect(Todo.Database, :store, fn(_, _) -> send home, :called! end)

    on_exit(fn ->
      :meck.unload(Todo.Database)
    end)

    :ok
  end

  test "Init" do
    {:ok, todo_server} = Todo.Server.start("test")
    assert Todo.Server.entries(todo_server, {2013, 12, 19}) ==
    [
      %{date: {2013, 12, 19}, id: 1, title: "Dentist"},
    ]
  end

  test "Add Entry" do
    {:ok, todo_server} = Todo.Server.start("test")
    Todo.Server.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})
    assert_receive :called!, 10
  end

end
