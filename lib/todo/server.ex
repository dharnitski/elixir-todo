defmodule Todo.Server do
  use GenServer

  def init(name) do
    {:ok, {Todo.Database.get(name) || Todo.List.new, name}}
  end

  #callback functions invoked in the server process
  def handle_cast({:add_entry, new_entry}, {list, name}) do
    new_state = Todo.List.add_entry(list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {new_state, name}}
  end
  def handle_cast({:delete_entry, entry_id}, {list, name}) do
    {:noreply, {Todo.List.delete_entry(list, entry_id), name}}
  end
  def handle_cast({:update_entry, entry}, {list, name}) do
    {:noreply, {Todo.List.update_entry(list, entry), name}}
  end

  def handle_call({:entries, date}, _, {list, name}) do
    {:reply, Todo.List.entries(list, date), {list, name}}
  end

  #interface functions
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:todo_server, name}}}
  end

  def whereis(name) do
    :gproc.whereis_name({:n, :l, {:todo_server, name}})
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  def update_entry(pid, %{} = new_entry) do
    GenServer.cast(pid, {:update_entry, new_entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end
end
