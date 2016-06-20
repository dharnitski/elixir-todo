defmodule Todo.TestHelper do

  def cleanup_gen_servers do
    for name <- [:todo_cache, :process_registry, :todo_server_supervisor] do
      case GenServer.whereis(name) do
        nil -> :ok
        pid ->
          GenServer.stop(pid)
      end
    end
  end

end
