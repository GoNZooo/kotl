defmodule KOTL.ID.Host do
  defstruct [:name]

  defimpl Inspect, for: KOTL.ID.Host do
    def inspect(%KOTL.ID.Host{name: name}, _) do
      "#Host<#{name}>"
    end
  end

  defimpl KOTL.Monitor.Check, for: KOTL.ID.Host do
    def heartbeat(id) do
      datetime = Timex.DateTime.universal
      name = KOTL.NameStore.lookup(id) |> String.to_char_list
      status = case :gen_icmp.ping(name) do
                 [{:error, reason, _, _}] ->
                   reason
                 [{:error, reason, _, _, _, _, _}] ->
                   reason
                 [{response, _, _, _, _, _}] ->
                   response
               end

      %KOTL.Heartbeat{datetime: datetime, status: status}
    end
  end
end
