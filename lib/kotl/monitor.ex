defmodule KOTL.Monitor do
  alias KOTL.Monitor.Check

  @spec check(%{name: atom}) :: :ok
  def check(id, interval \\ Application.get_env(:kotl, :interval)) do
    KOTL.Monitor.Manager.add_heartbeat(id, Check.heartbeat(id))
    :timer.sleep(interval)
    check(id, interval)
  end
end
