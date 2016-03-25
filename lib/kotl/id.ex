defmodule KOTL.ID do
  @type t :: %KOTL.ID{type: atom, name: (atom | String.t)}
  defstruct [:type, :name]
end
