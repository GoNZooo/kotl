defmodule KOTL.ID.Website do
  defstruct [:name]

  defimpl Inspect, for: KOTL.ID.Website do
    def inspect(%KOTL.ID.Website{name: name}, _) do
      "#Website<#{name}>"
    end
  end

  defimpl KOTL.Monitor.Check, for: KOTL.ID.Website do
    def heartbeat(id) do
      datetime = Timex.DateTime.universal
      location = KOTL.NameStore.lookup(id)
      status = KOTL.Monitor.Check.Website.check_site(location)

      %KOTL.Heartbeat{datetime: datetime, status: status}
    end

    def type_to_atom(_), do: :website
    def up_or_down(_, response) when response >= 400, do: :down
    def up_or_down(_, :error), do: :down
    def up_or_down(_, _), do: :up
  end
end
