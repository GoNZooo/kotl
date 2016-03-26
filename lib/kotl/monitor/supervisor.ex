defmodule KOTL.Monitor.Supervisor do
  @moduledoc"""
  Module to keep track of and supervise the Monitors. This is interacted with
  by the Monitor.Manager and only through that.
  """
  use Supervisor

  #######
  # API #
  #######

  @spec start_link([name: atom]) :: Supervisor.on_start()
  def start_link(opts \\ [name: __MODULE__]) do
    Task.Supervisor.start_link(opts)
  end

  @spec start_child(ID.t) :: Supervisor.Spec.on_start
  def start_child(id) do
    Task.Supervisor.start_child(__MODULE__, KOTL.Monitor, :check, [id])
  end

  ############
  # Internal #
  ############

  def init([]) do
    children = [
      worker(KOTL.Monitor, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
