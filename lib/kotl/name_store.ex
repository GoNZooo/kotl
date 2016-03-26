defmodule KOTL.NameStore do
  @moduledoc """
  Store for names and locations of other processes, machines and whatnot.

  In terms of implementation, is a key/value store, but the purpose is
  to store locations of different kinds.
  """

  use GenServer
  alias KOTL.ID

  #######
  # API #
  #######

  @spec start_link([%{type: atom,
                      name: (atom | String.t),
                      location: any}],
                   Keyword.t) :: {:ok, pid}
  def start_link(locs \\ Application.get_env(:kotl, :locations),
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, locs, opts)
  end

  @spec add(ID.t, any) :: :ok
  def add(id, location) do
    add(__MODULE__, id, location)
  end

  @spec add(pid, ID.t, any) :: :ok
  def add(pid, id, location) do
    GenServer.cast(pid, {:add, id, location})
  end

  @spec remove(ID.t) :: :ok
  def remove(id), do: remove(__MODULE__, id)

  @spec remove(pid, ID.t) :: :ok
  def remove(pid, id) do
    GenServer.cast(pid, {:remove, id})
  end

  @spec names :: [Location.t]
  def names, do: names(__MODULE__)

  @spec names(pid) :: [Location.t]
  def names(pid) do
    GenServer.call(pid, :names)
  end

  @spec lookup(ID.t) :: any
  def lookup(loc) do
    lookup(__MODULE__, loc)
  end

  @spec lookup(pid, ID.t) :: any
  def lookup(pid, loc) do
    GenServer.call(pid, {:lookup, loc})
  end

  ############
  # Internal #
  ############

  def init(names) do
    names = names |> Enum.into(%{},
      fn %{type: type, name: name, location: location} ->
        {%ID{type: type, name: name}, location}
      end)

    {:ok, names}
  end

  def handle_cast({:add, id, location}, locs) do
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
