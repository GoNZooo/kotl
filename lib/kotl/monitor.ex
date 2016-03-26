defmodule KOTL.Monitor do
  alias KOTL.ID
  alias KOTL.Heartbeat

  @spec heartbeat(%{type: :pid, name: (atom | String.t)}) :: Heartbeat.t
  def heartbeat(id = %ID{type: :pid}) do
    datetime = Timex.DateTime.universal
    status = KOTL.NameStore.lookup(id) |> Process.alive?
    %Heartbeat{datetime: datetime, status: status}
  end

  @spec heartbeat(%{type: :node, name: (atom | String.t)}) :: Heartbeat.t
  def heartbeat(id = %ID{type: :node}) do
    datetime = Timex.DateTime.universal
    status = KOTL.NameStore.lookup(id) |> Node.ping
    %Heartbeat{datetime: datetime, status: status}
  end

  @spec check(ID.t) :: :ok
  def check(id) do
    KOTL.Monitor.Manager.add_heartbeat(id, heartbeat(id))
  end
end
