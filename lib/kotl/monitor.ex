defmodule KOTL.Monitor do
  alias KOTL.Heartbeat
  alias KOTL.Monitor.Check

  @spec check(ID.t) :: :ok
  def check(id) do
    KOTL.Monitor.Manager.add_heartbeat(id, Check.heartbeat(id))
  end
end
