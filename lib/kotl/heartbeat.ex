defmodule KOTL.Heartbeat do
  @type t :: %KOTL.Heartbeat{datetime: Timex.DateTime.t,
                             response: pos_integer}
  defstruct [:datetime, :response]
end
