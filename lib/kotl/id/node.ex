defmodule KOTL.ID.Node do
  defstruct [:name]

  defimpl Inspect, for: KOTL.ID.Node do
    def inspect(%KOTL.ID.Node{name: name}, _) do
      "#Node<#{name}>"
    end
  end

  defimpl KOTL.Monitor.Check, for: KOTL.ID.Node do
    def heartbeat(id) do
      datetime = Timex.DateTime.universal
      status = KOTL.NameStore.lookup(id) |> Node.ping
      %KOTL.Heartbeat{datetime: datetime, status: status}
    end

    def type_to_atom(_), do: :node
    def up_or_down(_, :pong), do: :up
    def up_or_down(_, _), do: :down
  end
end
