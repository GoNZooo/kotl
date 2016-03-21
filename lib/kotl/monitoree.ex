defmodule KOTL.Monitoree do
  @moduledoc"""
  Stores information about a monitoree, which is a unit representing something
  that will have some kind of health/presence check done on it. This can be,
  for example, a host that will be pinged regularly or a process/node that will
  be pinged in much the same way.

  It embeds a list of heartbeats (a datetime + status, signifying a change in
  that status.) to store the historical data. This means that we can reconstruct
  historical data from the list of changes in status.
  """
  @type t :: %KOTL.Monitoree{location: KOTL.Location.t,
                             changes: [KOTL.Heartbeat.t]}
  defstruct [:location, :changes]
end
