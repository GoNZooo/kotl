defmodule KOTL.NameStore do
  @moduledoc """
  Store for names and locations of other processes, machines and whatnot.
  """
  use GenServer

  #######
  # API #
  #######

  def start_link(names \\ Map.new,
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, names, opts)
  end

  @spec add(atom | String.t, pid) :: :ok
  def add(name, location) do
    add(__MODULE__, name, location)
  end

  @spec add(pid, atom | String.t, pid) :: :ok
  def add(pid, name, location) do
    GenServer.cast(pid, {:add, name, location})
  end

  @spec remove(atom | String.t) :: :ok
  def remove(name) do
    remove(__MODULE__, name)
  end

  @spec remove(pid, atom | String.t) :: :ok
  def remove(pid, name) do
    GenServer.cast(pid, {:remove, name})
  end

  @spec names :: map
  def names do
    names(__MODULE__)
  end

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

  def handle_cast({:add, name, location}, names) do
    new_names = Map.put(names, name, location)
    {:noreply, new_names}
  end

  def handle_cast({:remove, name}, names) do
    new_names = Map.delete(names, name)
    {:noreply, new_names}
  end

  def handle_call(:names, _from, names) do
    {:reply, names, names}
  end
end
