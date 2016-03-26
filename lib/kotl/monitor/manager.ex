defmodule KOTL.Monitor.Manager do
  use GenServer
  alias KOTL.ID

  #######
  # API #
  #######

  @spec start_link([ID.t], [{atom, any}]) :: {:ok, pid}
  def start_link(monitorees \\ [], opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, monitorees, opts)
  end

  @spec add(ID.t) :: :ok
  def add(monitoree) do
    add(__MODULE__, monitoree)
  end

  @spec add(pid, ID.t) :: :ok
  def add(pid, monitoree) do
    GenServer.cast(pid, {:add, monitoree})
  end

  @spec remove(ID.t) :: :ok
  def remove(monitoree) do
    remove(__MODULE__, monitoree)
  end

  @spec remove(pid, ID.t) :: :ok
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

  @spec changes(ID.t) :: [Heartbeat.t]
  def changes(id) do
    changes(__MODULE__, id)
  end

  @spec changes(pid, ID.t) :: [Heartbeat.t]
  def changes(pid, id) do
    GenServer.call(pid, {:changes, id})
  end

  @spec add_heartbeat(ID.t, Heartbeat.t) :: :ok
  def add_heartbeat(id, heartbeat) do
    add_heartbeat(__MODULE__, id, heartbeat)
  end

  @spec add_heartbeat(ID.t, Heartbeat.t) :: :ok
  def add_heartbeat(pid, id, heartbeat) do
    GenServer.cast(pid, {:add_heartbeat, id, heartbeat})
  end

  ############
  # Internal #
  ############

  def init(monitorees) do
    monitoree_map = Enum.into(monitorees, %{}, &({&1, []}))

    {:ok, monitoree_map}
  end

  def handle_call(:monitorees, _from, monitorees) do
    {:reply, monitorees, monitorees}
  end

  def handle_call({:changes, id}, _from, monitorees) do
    {:reply, Map.get(monitorees, id), monitorees}
  end

  def handle_cast({:add, mon}, monitorees) do
    new_monitorees = Map.put(monitorees, mon, [])

    {:noreply, new_monitorees}
  end

  def handle_cast({:remove, mon}, monitorees) do
    new_monitorees = Map.delete(monitorees, mon)

    {:noreply, new_monitorees}
  end

  def handle_cast({:add_heartbeat, id, heartbeat}, monitorees) do
    changes = Map.get(monitorees, id, [])
    new_changes =
      case changes do
        [] -> [heartbeat]
        [last_change | rest] ->
          if last_change.status != heartbeat.status do
            [heartbeat | changes]
          else
            changes
          end
      end
    new_monitorees = Map.put(monitorees, id, new_changes)

    {:noreply, new_monitorees}
  end
end
