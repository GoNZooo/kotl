defmodule KOTL.Heartbeat do
  @moduledoc"""
  Stores a datetime and a result. The result is a positive integer representing
  the time it took to get a response from a server or the like, meaning for
  example a ping to a hostname to see if it's up or not.
  """
  @type t :: %KOTL.Heartbeat{datetime: Timex.DateTime.t,
                             response: integer}
  defstruct [:datetime, :response]
end
