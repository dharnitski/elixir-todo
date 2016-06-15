defmodule Todo.Supervisor.Test do
  use ExUnit.Case

  setup do
    case GenServer.whereis(:todo_cache) do
      nil -> :ok
      pid ->
        GenServer.stop(pid)
    end
  end

  test "Supervisor" do
    Todo.Supervisor.start_link
  end

end
