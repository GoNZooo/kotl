defmodule KOTL.Monitor do
  alias KOTL.Monitoree
  alias KOTL.Location
  alias KOTL.Heartbeat

  def monitor(monitoree = %Monitoree{location: loc = %Location{name: name,
                                                               location: pid,
                                                               type: :pid},
                                     changes: changes}) do
    last_change = List.last(changes)
    last_status = last_change.status
    current_status = Process.alive?(pid)
    if last_status == current_status do
      current_datetime = Timex.DateTime.universal
      %Monitoree{location: loc,
                 changes: changes ++ %Heartbeat{datetime: current_datetime,
                                                status: current_status}}
    else
      monitoree
    end
  end
end
