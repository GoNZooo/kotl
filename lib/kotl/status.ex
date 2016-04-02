defmodule KOTL.Status do
  defstruct [:type, :name, :status]

  defimpl Inspect, for: KOTL.Status do
    def inspect(%KOTL.Status{type: type, name: name, status: status}, _) do
      "#Status<#{type}, #{name}, #{status}>"
    end
  end

  defimpl Poison.Encoder, for: KOTL.Status do
    def encode(status, opts) do
      %{type: status.type,
        name: status.name,
        status: status.status} |> Poison.Encoder.encode(opts)
    end
  end
end
