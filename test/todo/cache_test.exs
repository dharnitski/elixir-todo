defmodule Todo.Cache.Test do
  use ExUnit.Case

  test "Cache" do
    {:ok, cache} = Todo.Cache.start
    bobs1 = Todo.Cache.server_process(cache, "Bob's list")
    bobs2 = Todo.Cache.server_process(cache, "Bob's list")
    alice1 = Todo.Cache.server_process(cache, "Alice's list")
    assert bobs1 == bobs2
    #todo test !=
    #assert bobs1 != alice1
  end

end
