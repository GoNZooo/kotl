defmodule KOTL.Monitor.Spawner.Supervisor do
  use Supervisor

  #######
  # API #
  #######

  def start_link(opts \\ [name: __MODULE__]) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  ############
  # Internal #
  ############

  def init([]) do
    children = [
      worker(KOTL.Monitor.Spawner, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
