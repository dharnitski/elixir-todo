defmodule Todo.Database do
  @pool_size 3

  def start_link(db_folder) do
    Todo.PoolSupervisor.start_link(db_folder, @pool_size)
  end

  def store_local(key, data) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def store(key, data) do
    {results, bad_nodes} = :rpc.multicall(
        __MODULE__, :store_local, [key, data], :timer.seconds(5)
      )

    #logs failed results
    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))

    :ok  
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  # Choosing a worker makes a request to the :database_server process. There we
  # keep the knowledge about our workers, and return the pid of the corresponding
  # worker. Once this is done, the caller process will talk to the worker directly.
  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

end
