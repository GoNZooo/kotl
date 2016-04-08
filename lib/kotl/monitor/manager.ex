defmodule KOTL.Monitor.Manager do
  use GenServer
  alias KOTL.Monitor.Supervisor, as: MonitorSuper
  alias KOTL.Monitor.Check
  alias KOTL.{Status,Heartbeat}
  require Logger

  #######
  # API #
  #######

  @spec start_link([%{name: String.t}], [{atom, any}]) :: {:ok, pid}
  def start_link(monitorees \\ [], opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, monitorees, opts)
  end

  @spec add(%{name: String.t}) :: :ok
  def add(monitoree) do
    add(__MODULE__, monitoree)
  end

  @spec add(pid, %{name: String.t}) :: :ok
  def add(pid, monitoree) do
    GenServer.cast(pid, {:add, monitoree})
  end

  @spec remove(%{name: String.t}) :: :ok
  def remove(monitoree) do
    remove(__MODULE__, monitoree)
  end

  @spec remove(pid, %{name: String.t}) :: :ok
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

  @spec changes(%{name: String.t}) :: [Heartbeat.t]
  def changes(id) do
    changes(__MODULE__, id)
  end

  @spec changes(pid, %{name: String.t}) :: [Heartbeat.t]
  def changes(pid, id) do
    GenServer.call(pid, {:changes, id})
  end

  @spec add_heartbeat(%{name: String.t}, Heartbeat.t) :: :ok
  def add_heartbeat(id, heartbeat) do
    add_heartbeat(__MODULE__, id, heartbeat)
  end

  @spec add_heartbeat(%{name: String.t}, Heartbeat.t) :: :ok
  def add_heartbeat(pid, id, heartbeat) do
    GenServer.cast(pid, {:add_heartbeat, id, heartbeat})
  end

  @spec current_statuses :: map
  def current_statuses do
    current_statuses(__MODULE__)
  end

  @spec current_statuses(pid) :: map
  def current_statuses(pid) do
    GenServer.call(pid, :current_statuses)
  end

  ############
  # Internal #
  ############

  defp _current_status({id, %{changes: []}}) do
    %Status{type: Check.type_to_atom(id),
            name: id.name,
            status: :unknown}
  end

  defp _current_status({id, %{changes: [%Heartbeat{status: status} | _]}}) do
    %Status{type: Check.type_to_atom(id),
            name: id.name,
            status: Check.up_or_down(id, status)}
  end

  defp _current_statuses(monitorees) do
    Enum.map(monitorees, &_current_status/1)
  end

  defp init_monitor(id) do
    {:ok, pid} = MonitorSuper.start_child(id)
    %{changes: [], pid: pid}
  end
  
  defp init_monitor(id, changes) do
    {:ok, pid} = MonitorSuper.start_child(id)
    %{changes: changes, pid: pid}
  end

  def init(monitorees) do
    monitoree_map = Enum.into(monitorees, %{}, &({&1, init_monitor(&1)}))

    {:ok, monitoree_map}
  end

  def handle_call(:monitorees, _from, monitorees) do
    {:reply, monitorees, monitorees}
  end

  def handle_call({:changes, id}, _from, monitorees) do
    {:reply, Map.get(monitorees, id), monitorees}
  end

  def handle_call(:current_statuses, _from, monitorees) do
    {:reply, _current_statuses(monitorees), monitorees}
  end

  def handle_cast({:add, mon}, monitorees) do
    new_monitorees = Map.put(monitorees, mon, init_monitor(mon))

    {:noreply, new_monitorees}
  end

  def handle_cast({:remove, mon}, monitorees) do
    %{pid: monitor_pid} = Map.get(monitorees, mon)
    MonitorSuper.terminate_child(monitor_pid)
    new_monitorees = Map.delete(monitorees, mon)

    {:noreply, new_monitorees}
  end

  def handle_cast({:add_heartbeat, id, heartbeat}, monitorees) do
    monitoree_data = %{changes: changes} = Map.get(monitorees, id)
    new_changes =
      case changes do
        [] -> [heartbeat]
        [last_change | _] ->
          if last_change.status != heartbeat.status do
            [heartbeat | changes]
          else
            changes
          end
      end
    new_monitorees = Map.put(monitorees,
                             id,
                             %{monitoree_data | changes: new_changes})

    {:noreply, new_monitorees}
  end
end
