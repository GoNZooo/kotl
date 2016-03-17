defmodule KOTL.Monitoree do
  @moduledoc"""
  Stores information about a monitoree, which is a unit representing something
  that will have some kind of health/presence check done on it. This can be,
  for example, a host that will be pinged regularly or a process/node that will
  be pinged in much the same way.

  It embeds a list of heartbeats (results comprised of datetime + response time)
  to store the historical data.
  """
  @type t :: %KOTL.Monitoree{location: KOTL.Location.t,
                             data: [KOTL.Heartbeat.t]}
  defstruct [:location, :data]
end
