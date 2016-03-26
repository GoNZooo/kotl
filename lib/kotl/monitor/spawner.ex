defmodule KOTL.Monitor.Spawner do
  alias KOTL.Monitor.Supervisor, as: MonSup
  alias KOTL.Monitor.Manager, as: MonMag

  def start_link(interval \\ 60_000) do
    Task.start_link(fn -> spawn_loop(interval) end)
  end

  def spawn_loop(interval) do
    monitorees = MonMag.monitorees
    |> Enum.map(fn {mon, _} -> mon end)

    Enum.each(monitorees, &(MonSup.start_child(&1)))
    :timer.sleep(interval)
    spawn_loop(interval)
  end
end
