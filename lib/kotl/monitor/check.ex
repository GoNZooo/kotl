defprotocol KOTL.Monitor.Check do
  def heartbeat(id)
  def type_to_atom(id)
  def up_or_down(id, status)
end
