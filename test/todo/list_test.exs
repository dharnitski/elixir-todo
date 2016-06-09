defmodule Todo.List.Test do
  use ExUnit.Case
  doctest Todo.List

  test "Should update Entry" do
    assert Todo.List.new
    |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "Dentist"})
    |> Todo.List.update_entry(%{date: {2014, 12, 19}, id: 1, title: "Dentist"}) ==
    %Todo.List{auto_id: 2, entries: %{1 => %{date: {2014, 12, 19}, id: 1, title: "Dentist"}}}
  end

  test "Not Existing id should return current data" do
    assert Todo.List.new
    |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "Dentist"})
    |> Todo.List.update_entry(%{date: {2014, 12, 19}, id: 42, title: "Dentist"}) ==
    %Todo.List{auto_id: 2, entries: %{1 => %{date: {2013, 12, 19}, id: 1, title: "Dentist"}}}
  end

  test "Update Entry should check data type" do
    assert_raise FunctionClauseError, fn ->
      Todo.List.update_entry("not valid type", %{date: {2014, 12, 19}, id: 1, title: "Dentist"})
    end
  end

  test "Lambda in Update Entry should return Map" do
    assert_raise FunctionClauseError, fn ->
      Todo.List.new
        |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "Dentist"})
        |> Todo.List.update_entry("Not Map")
    end
  end

  test "Deletion of not existing id should keep enrties intact" do
    assert Todo.List.new
    |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "Dentist"})
    |> Todo.List.delete_entry(2) ==
    %Todo.List{auto_id: 2, entries: %{1 => %{date: {2013, 12, 19}, id: 1, title: "Dentist"}}}
  end

  test "Import from file" do
    todo_list = Todo.List.CsvImporter.import("test/todo/todos.csv")
    assert todo_list == %Todo.List{auto_id: 4,
            entries: %{
              1 => %{date: {2013, 12, 19}, id: 1, title: "Dentist"},
              2 => %{date: {2013, 12, 20}, id: 2, title: "Shopping"},
              3 => %{date: {2013, 12, 19}, id: 3, title: "Movies"}
            }
          }
  end

  test "To String protocol" do
    assert String.Chars.to_string(Todo.List.new()) == "#Todo.List"
  end

  test "Collectable protocol" do
    entries = [
      %{date: {2013, 12, 19}, title: "Dentist"},
      %{date: {2014, 12, 19}, title: "Movie"}
      ]
    assert Enum.into(entries, Todo.List.new) ==
    %Todo.List{auto_id: 3,
            entries: %{1 => %{date: {2013, 12, 19}, id: 1,
                title: "Dentist"},
              2 => %{date: {2014, 12, 19}, id: 2, title: "Movie"}}}
  end

end
