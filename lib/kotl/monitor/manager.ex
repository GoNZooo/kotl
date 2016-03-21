defmodule KOTL.Monitor.Manager do
  use GenServer
  alias KOTL.Monitoree
  alias KOTL.Monitor.Supervisor, as: MonSup

  @todo"""
  Integrate result storing as well as make strategy for continued checking
  of monitorees. Implement an incremental backoff strategy so that an unavailable
  host isn't pinged as much after longer unavailability.
  """

  #######
  # API #
  #######

  def start_link(monitorees \\ [], opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, monitorees, opts)
  end

  def add(monitoree) do
    add(__MODULE__, monitoree)
  end

  def add(pid, monitoree) do
    GenServer.cast(pid, {:add, monitoree})
  end

  def remove(monitoree) do
    remove(__MODULE__, monitoree)
  end

  def remove(pid, monitoree) do
    GenServer.cast(pid, {:remove, monitoree})
  end

  def monitorees do
    monitorees(__MODULE__)
  end

  def monitorees(pid) do
    GenServer.call(pid, :monitorees)
  end

  def whereis(monitoree) do
    whereis(__MODULE__, monitoree)
  end

  def whereis(pid, monitoree) do
    GenServer.call(pid, {:whereis, monitoree})
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

  def handle_call({:whereis, monitoree}, _from, monitorees) do
    {:reply, Map.get(monitoree), monitorees}
  end

  def handle_cast({:add, mon}, monitorees) do
    new_monitorees = Map.put(monitorees, mon, MonSup.start_child(mon))
    {:noreply, new_monitorees}
  end

  def handle_cast({:remove, monitoree}, monitorees) do
    MonSup.terminate_child(monitoree)
    new_monitorees = Map.delete(monitorees, monitoree)
    {:noreply, new_monitorees}
  end
end
