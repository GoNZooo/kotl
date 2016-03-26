# KOTL

## What is it?
KOTL is a nameserver application with built-in monitoring for registered items.

## How do I use it?
We start a named session of iex: `iex --sname local -S mix`.
This session will automatically load the KOTL application.

We start another session (loading KOTL is not necessary in this one):
`iex --sname remote`

In our 'local' session we'll create an ID and add it to the NameStore:

    iex(local@omniknight)1> id = %KOTL.ID{type: :node, name: :remote}
    %KOTL.ID{name: :remote, type: :node}
    iex(local@omniknight)2> KOTL.NameStore.add(id, :remote@omniknight)
    :ok
    
We'll now add the ID to our MonitorManager so that it will be monitored:

    iex(local@omniknight)3> KOTL.Monitor.Manager.add(id)
    :ok

After a certain amount of time (the sleep interval setting in the config)
a first lookup will be done of the node and calling `Monitor.Manager.monitorees`
will give you the list of the monitorees and their recent status changes:

    iex(local@omniknight)4> KOTL.Monitor.Manager.monitorees
    %{%KOTL.ID{name: :remote,
       type: :node} => [%KOTL.Heartbeat{datetime: #<DateTime(2016-03-26T21:23:45Z)>,
           status: :pong}]}
           
When a monitoree's status changes the change will be logged in the list of the
monitorees, giving something like the following:

    iex(local@omniknight)5> KOTL.Monitor.Manager.monitorees
    %{%KOTL.ID{name: :remote,
       type: :node} => [%KOTL.Heartbeat{datetime: #<DateTime(2016-03-26T21:34:45Z)>,
           status: :pang},
              %KOTL.Heartbeat{datetime: #<DateTime(2016-03-26T21:23:45Z)>, status: :pong}]}

The first item in the status list is now a `%Heartbeat{}` struct with the status
`:pang`, which indicates that the node is not responsive.

If it were to resurface, it would look something like this:

    iex(local@omniknight)6> KOTL.Monitor.Manager.monitorees
    %{%KOTL.ID{name: :remote,
       type: :node} => [%KOTL.Heartbeat{datetime: #<DateTime(2016-03-26T21:35:45Z)>,
           status: :pong},
              %KOTL.Heartbeat{datetime: #<DateTime(2016-03-26T21:34:45Z)>, status: :pang},
                 %KOTL.Heartbeat{datetime: #<DateTime(2016-03-26T21:23:45Z)>, status: :pong}]}

We now have a sequence of status updates, logged only when they differ from
eachother, meaning that we have a log of relevant status changes.

## How do I install it?
Currently, KOTL is only available through GitHub.

  1. Add KOTL to your list of dependencies in `mix.exs`:

        def deps do
          [{:kotl, git: "git://github.com/gonzooo/kotl.git}]
        end

  2. Ensure KOTL is started before your application:

        def application do
          [applications: [:kotl]]
        end

