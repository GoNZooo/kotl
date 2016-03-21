defmodule KOTL.Monitor.Supervisor do
  @moduledoc"""
  Module to keep track of and supervise the Monitors. This is interacted with
  by the Monitor.Manager and only through that.
  """
  use Supervisor
  alias KOTL.Monitoree

  #######
  # API #
  #######

  @spec start_link([name: atom]) :: Supervisor.on_start
  def start_link(__MODULE__, [], opts \\ [name: __MODULE__]) do
    Supervisor.start_link([], opts)
  end

  @spec start_child(Monitoree.t) :: {:ok, pid}
  def start_child(monitoree) do
    Supervisor.start_child(__MODULE__, [monitoree])
  end

  @spec terminate_child(Monitoree.t) :: :ok
  def terminate_child(monitoree) do
    child_pid = KOTL.Manager.whereis(monitoree)
    Supervisor.terminate_child(__MODULE__, child_pid)
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
