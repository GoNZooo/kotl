defmodule KOTL.Location do
  defstruct [:type, :name, :location]
  @type t :: %KOTL.Location{type: atom,
                            name: (atom | String.t),
                            location: (atom | String.t)}
end
