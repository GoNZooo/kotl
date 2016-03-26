defmodule KOTL do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(KOTL.Worker, [arg1, arg2, arg3]),
      worker(KOTL.NameStore, [[]]), # empty list as first arg
      supervisor(KOTL.Monitor.Supervisor, []),
      worker(KOTL.Monitor.Manager, []),
      supervisor(KOTL.Monitor.Spawner.Supervisor, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KOTL.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
