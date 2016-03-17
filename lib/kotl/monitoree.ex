defmodule KOTL.Monitoree do
  @type t :: %KOTL.Monitoree{location: KOTL.Location.t,
                             data: [KOTL.Heartbeat.t]}
  defstruct [:location, :data]
end
