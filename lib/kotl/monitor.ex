defmodule KOTL.Monitor do
  use GenServer

  #######
  # API #
  #######

  def start_link(monitorees \\ [], opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, monitorees, opts)
  end

  def add(monitoree) do
    add(__MODULE__, monitoree)
  end

  def add(pid, monitoree) do
    GenServer.cast(pid, {:add, monitoree})
  end

  def remove(monitoree) do
    remove(__MODULE__, monitoree)
  end

  def remove(pid, monitoree) do
    GenServer.cast(pid, {:remove, monitoree})
  end

  def monitorees do
    monitorees(__MODULE__)
  end

  def monitorees(pid) do
    GenServer.call(pid, :monitorees)
  end

  ############
  # Internal #
  ############

  def handle_call(:monitorees, _from, monitorees) do
    {:reply, monitorees, monitorees}
  end

  def handle_cast({:add, monitoree}, monitorees) do
    {:noreply, [monitoree | monitorees]}
  end

  def handle_cast({:remove, monitoree}, monitorees) do
    new_monitorees = Enum.reject(monitorees, &(&1 == monitoree))
    {:noreply, new_monitorees}
  end
end
