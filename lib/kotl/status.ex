defmodule KOTL.Status do
  defstruct [:type, :name, :status]

  defimpl Inspect, for: KOTL.Status do
    def inspect(%KOTL.Status{type: type, name: name, status: status}, _) do
      "#Status<#{type}, #{name}, #{status}>"
    end
  end
end
