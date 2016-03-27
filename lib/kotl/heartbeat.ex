defmodule KOTL.Heartbeat do
  @moduledoc"""
  Stores a datetime and a status. This should be something like :up/:down.

  This means that we'll store the last change of the status.
  """
  @type t :: %KOTL.Heartbeat{datetime: Timex.DateTime.t, status: any}
  defstruct [:datetime, :status]

  defimpl Inspect, for: KOTL.Heartbeat do
    def inspect(%KOTL.Heartbeat{datetime: datetime, status: status}, _) do
      {:ok, datetime_string} = Timex.format(datetime, "%FT%T%:z", :strftime)
      "#Heartbeat<#{datetime_string} -> #{status}>"
    end
  end
end
