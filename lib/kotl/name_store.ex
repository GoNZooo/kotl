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

  def start_link(locations \\ _init_locations(Application.get_env(:kotl, :locations)),
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, locations, opts)
  end

  @spec add(Location.t) :: :ok
  def add(location = %Location{type: type, name: name})
  when not is_nil(type) and not is_nil(name) do
    add(__MODULE__, location)
  end

  @spec add(pid, Location.t) :: :ok
  def add(pid, location = %Location{type: type, name: name})
  when not is_nil(type) and not is_nil(name) do
    GenServer.cast(pid, {:add, location})
  end

  @spec remove(Location.t) :: :ok
  def remove(location), do: remove(__MODULE__, location)

  @spec remove(pid, Location.t) :: :ok
  def remove(pid, location = %Location{type: type, name: name})
  when not is_nil(type) and not is_nil(name) do
    GenServer.cast(pid, {:remove, location})
  end

  @spec locations :: [Location.t]
  def locations, do: locations(__MODULE__)

  @spec locations(pid) :: [Location.t]
  def locations(pid) do
    GenServer.call(pid, :locations)
  end

  @spec search(:name, atom | String.t) :: [Location.t]
  def search(:name, name) do
    search(__MODULE__, :name, name)
  end

  @spec search(:type, atom) :: [Location.t]
  def search(:type, type) do
    search(__MODULE__, :type, type)
  end

  @spec search(pid, :name, atom | String.t) :: [Location.t]
  def search(pid, :name, name) do
    GenServer.call(pid, {:search, :name, name})
  end

  @spec search(pid, :type, atom) :: [Location.t]
  def search(pid, :type, type) when is_atom(type) do
    GenServer.call(pid, {:search, :type, type})
  end

  ############
  # Internal #
  ############

  defp _init_locations(locs) do
    Enum.map(locs,
      fn %{type: type, name: name, location: location} ->
        %Location{type: type, name: name, location: location}
        end)
  end

  def init(locations) do
    {:ok, locations}
  end

  def handle_cast({:add, spec}, locations) do
    new_locations = [spec | locations]
    {:noreply, new_locations}
  end

  def handle_cast({:remove, spec}, locations) do
    new_locations = Enum.reject(locations, &(&1 == spec))
    {:noreply, new_locations}
  end

  def handle_call(:locations, _from, locations) do
    {:reply, locations, locations}
  end

  def handle_call({:search, :name, name}, _from, locations) do
    found = Enum.filter(locations, &(&1.name == name))
    {:reply, found, locations}
  end

  def handle_call({:search, :type, type}, _from, locations) do
    found = Enum.filter(locations, &(&1.type == type))
    {:reply, found, locations}
  end
end
