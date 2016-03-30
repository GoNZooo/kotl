defmodule KOTL.NameStore do
  @moduledoc """
  Store for names and locations of other processes, machines and whatnot.

  In terms of implementation, is a key/value store, but the purpose is
  to store locations of different kinds.
  """

  use GenServer

  #######
  # API #
  #######

  @spec start_link(Keyword.t) :: {:ok, pid}
  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @spec add(%{name: atom}, any) :: :ok
  def add(id, location) do
    add(__MODULE__, id, location, [auto_add: true])
  end

  @spec add(pid, %{name: atom}, any, Keyword.t) :: :ok
  def add(pid, id, location, opts) do
    GenServer.cast(pid, {:add, id, location, opts})
  end

  @spec remove(%{name: atom}) :: :ok
  def remove(id), do: remove(__MODULE__, id)

  @spec remove(pid, %{name: atom}) :: :ok
  def remove(pid, id) do
    GenServer.cast(pid, {:remove, id})
  end

  @spec names :: map
  def names, do: names(__MODULE__)

  @spec names(pid) :: map
  def names(pid) do
    GenServer.call(pid, :names)
  end

  @spec lookup(%{name: atom}) :: any
  def lookup(loc) do
    lookup(__MODULE__, loc)
  end

  @spec lookup(pid, %{name: atom}) :: any
  def lookup(pid, loc) do
    GenServer.call(pid, {:lookup, loc})
  end

  ############
  # Internal #
  ############

  def init(%{}) do
    {:ok, %{}}
  end

  def handle_cast({:add, id, location, [auto_add: true]}, locs) do
    KOTL.Monitor.Manager.add(id)
    {:noreply, Map.put(locs, id, location)}
  end
  
  def handle_cast({:add, id, location, [auto_add: false]}, locs) do
    {:noreply, Map.put(locs, id, location)}
  end

  def handle_cast({:remove, id}, locs) do
    {:noreply, Map.delete(locs, id)}
  end

  def handle_call(:names, _from, names) do
    {:reply, names, names}
  end

  def handle_call({:lookup, id}, _from, locs) do
    {:reply, Map.get(locs, id), locs}
  end
end
