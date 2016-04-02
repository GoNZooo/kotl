defmodule KOTL.ID.Process do
  defstruct [:name]
  @type t :: %KOTL.ID.Process{name: atom}

  defimpl Inspect, for: KOTL.ID.Process do
    def inspect(%KOTL.ID.Process{name: name}, _) do
      "#Process<#{name}>"
    end
  end

  defimpl KOTL.Monitor.Check, for: KOTL.ID.Process do
    def heartbeat(id) do
      datetime = Timex.DateTime.universal
      status = KOTL.NameStore.lookup(id) |> Process.alive?
      %KOTL.Heartbeat{datetime: datetime, status: status}
    end

    def type_to_atom(_), do: :process
    def up_or_down(_, :pong), do: :up
    def up_or_down(_, _), do: :down
  end
end
