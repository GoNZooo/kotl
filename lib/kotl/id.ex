defmodule KOTL.ID do
  @type t :: %KOTL.ID{type: atom, name: (atom | String.t)}
  defstruct [:type, :name]

  defimpl Inspect, for: KOTL.ID do
    def inspect(%KOTL.ID{type: type, name: name}, _) do
      "#ID<#{type}, #{name}>"
    end
  end

end
