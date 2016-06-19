defmodule Todo.Cache do
  use GenServer

  def init(_) do
    {:ok, Map.new}
  end

  def handle_call({:server_process, todo_list_name}, _, state) do
    # We need to recheck once again if the server exists.
    todo_server_pid = case Todo.Server.whereis(todo_list_name) do
      :undefined ->
        {:ok, pid} = Todo.ServerSupervisor.start_child(todo_list_name)
        pid

      pid -> pid
    end
    {:reply, todo_server_pid, state}
  end

  #interface functions
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(todo_list_name) do
    case Todo.Server.whereis(todo_list_name) do
      :undefined ->
        # There's no to-do server, so we'll issue request to the cache process.
        GenServer.call(:todo_cache, {:server_process, todo_list_name})

      pid -> pid
    end
  end
end
