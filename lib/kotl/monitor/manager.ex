defmodule KOTL.Monitor.Manager do
  use GenServer
  alias KOTL.Monitoree
  alias KOTL.Monitor.Supervisor, as: MonSup

  #######
  # API #
  #######

  @spec start_link([Monitoree.t], [{atom, any}]) :: {:ok, pid}
  def start_link(monitorees \\ [], opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, monitorees, opts)
  end

  @spec add(Monitoree.t) :: :ok
  def add(monitoree) do
    add(__MODULE__, monitoree)
  end

  @spec add(pid, Monitoree.t) :: :ok
  def add(pid, monitoree) do
    GenServer.cast(pid, {:add, monitoree})
  end

  @spec remove(Monitoree.t) :: :ok
  def remove(monitoree) do
    remove(__MODULE__, monitoree)
  end

  @spec remove(pid, Monitoree.t) :: :ok
  def remove(pid, monitoree) do
    GenServer.cast(pid, {:remove, monitoree})
  end

  @spec monitorees :: map
  def monitorees do
    monitorees(__MODULE__)
  end

  @spec monitorees(pid) :: map
  def monitorees(pid) do
    GenServer.call(pid, :monitorees)
  end

  ############
  # Internal #
  ############

  def init(monitorees) do
    monitoree_hash = Enum.map(monitorees, &({MonSup.start_child(&1), &1}))
    |> Enum.into(%{}, fn {{:ok, pid}, mon} -> {mon, pid} end)

    {:ok, monitoree_hash}
  end

  def handle_call(:monitorees, _from, monitorees) do
    {:reply, monitorees, monitorees}
  end

  def handle_cast({:add, mon}, monitorees) do
    new_monitorees = Map.put(monitorees, mon, MonSup.start_child(mon))

    {:noreply, new_monitorees}
  end

  def handle_cast({:remove, monitoree}, monitorees) do
    Map.get(monitorees, monitoree) |> MonSup.terminate_child
    new_monitorees = Map.delete(monitorees, monitoree)

    {:noreply, new_monitorees}
  end
end
