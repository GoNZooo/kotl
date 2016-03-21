defmodule KOTL.Heartbeat do
  @moduledoc"""
  Stores a datetime and a status. This should be something like :up/:down.

  This means that we'll store the last change of the status.
  """
  @type t :: %KOTL.Heartbeat{datetime: Timex.DateTime.t,
                             status: atom}
  defstruct [:datetime, :status]
end
