defmodule KOTL.NameStore do
  @moduledoc """
  Store for names and locations of other processes, machines and whatnot.

  In terms of implementation, is a key/value store, but the purpose is
  to store locations of different kinds. This is enforced through using
  the Location struct and the Location.t type.
  """

  use GenServer
  alias KOTL.Location

  #######
  # API #
  #######

  def start_link(names \\ Application.get_env(:kotl, :names),
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, names, opts)
  end

  @spec add(Location.t) :: :ok
  def add(spec = %Location{type: type, name: name})
  when not is_nil(type) and not is_nil(name) do
    add(__MODULE__, spec)
  end

  @spec add(pid, Location.t) :: :ok
  def add(pid, spec = %Location{type: type, name: name})
  when not is_nil(type) and not is_nil(name) do
    GenServer.cast(pid, {:add, spec})
  end

  @spec remove({atom, atom | String.t}) :: :ok
  def remove({type, name}) do
    remove(__MODULE__, %Location{type: type, name: name})
  end

  @spec remove(Location.t) :: :ok
  def remove(spec = %Location{type: type, name: name})
  when not is_nil(type) and not is_nil(name) do
    remove(__MODULE__, spec)
  end

  @spec remove(pid, atom | String.t) :: :ok
  def remove(pid, {type, name}) do
    remove(pid, %Location{type: type, name: name})
  end

  @spec remove(pid, Location.t) :: :ok
  def remove(pid, spec = %Location{type: type, name: name})
  when not is_nil(type) and not is_nil(name) do
    GenServer.cast(pid, {:remove, spec})
  end

  @spec names :: map
  def names, do: names(__MODULE__)

  @spec names(pid) :: map
  def names(pid) do
    GenServer.call(pid, :names)
  end

  ############
  # Internal #
  ############

  def init(names) do
    {:ok, names}
  end

  def handle_cast({:add, spec}, names) do
    new_names = Map.put(names, {spec.type, spec.name}, spec.location)
    {:noreply, new_names}
  end

  def handle_cast({:remove, spec}, names) do
    new_names = Map.delete(names, {spec.type, spec.name})
    {:noreply, new_names}
  end

  def handle_call(:names, _from, names) do
    {:reply, names, names}
  end
end
