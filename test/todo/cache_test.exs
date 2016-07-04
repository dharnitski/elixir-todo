defmodule Todo.Cache.Test do
  use ExUnit.Case

  import Mock

  test "Server already started" do
    with_mock Todo.Server, [whereis: fn(_) -> self end] do
      assert self == Todo.Cache.server_process("Bob's list")
    end
  end

  test "Supervisor creates a new server" do
    with_mock Todo.Server, [whereis: fn(_) -> :undefined end] do
      with_mock Todo.ServerSupervisor, [start_child: fn(_) -> {:ok, self} end] do
        assert self == Todo.Cache.server_process("Bob's list")
      end
    end
  end

  test "Supervisor returns existing server" do
    with_mock Todo.Server, [whereis: fn(_) -> :undefined end] do
      with_mock Todo.ServerSupervisor,
        [start_child: fn(_) -> {:error, {:already_started, self}} end] do
        assert self == Todo.Cache.server_process("Bob's list")
      end
    end
  end

end
