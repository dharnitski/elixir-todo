defmodule Todo.Web.Test do
  use ExUnit.Case
  use Plug.Test

  import Mock

  @opts Todo.Web.init([])

  test "returns empty entries" do
    with_mock Todo.Cache,
      [server_process: fn(_) -> nil end] do
      with_mock Todo.Server,
        [entries: fn(_, _) -> [] end] do

        conn = conn(:get, "/entries?list=bob&date=20131219", "")
          |> Todo.Web.call(@opts)

        assert conn.state == :sent
        assert conn.status == 200
      end
    end
  end

  test "returns one entry" do
    with_mock Todo.Cache,
      [server_process: fn(_) -> nil end] do
      with_mock Todo.Server,
        [entries: fn(_, _) -> [%{date: {2013, 12, 19}, id: 1, title: "Dentist"}] end] do

        conn = conn(:get, "/entries?list=bob&date=20131219", "")
          |> Todo.Web.call(@opts)

        assert conn.state == :sent
        assert conn.status == 200
        assert conn.resp_body == "2013-12-19    Dentist"
      end
    end
  end

  test "add entry" do
    with_mock Todo.Cache,
      [server_process: fn(_) -> nil end] do
      with_mock Todo.Server,
        [add_entry: fn(_, %{date: {2013, 12, 19}, title: "Dentist"}) -> nil end] do

        conn = conn(:post, "/add_entry?list=bob&date=20131219&title=Dentist", "")
          |> Todo.Web.call(@opts)

        assert conn.state == :sent
        assert conn.status == 200
      end
    end
  end

  test "Application Start" do
    Todo.Web.start_server
    assert :ok = Plug.Adapters.Cowboy.shutdown(Todo.Web.HTTP)
  end

  test "returns 404" do
    conn = conn(:get, "/missing", "")
           |> Todo.Web.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
