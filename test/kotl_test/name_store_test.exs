defmodule KOTLTest.NameStoreTest do
  use ExUnit.Case
  doctest KOTL.NameStore
  alias KOTL.Location

  test "basic functionality, name" do
    {:ok, _} = KOTL.NameStore.start_link([])
    [] = KOTL.NameStore.names
    KOTL.NameStore.add(%Location{type: :pid, name: :self, location: self})
    this = self()
    [%Location{type: :pid, name: :self, location: this}] = KOTL.NameStore.names
  end

  test "basic functionality, pid" do
    {:ok, pid} = KOTL.NameStore.start_link([])
    [] = KOTL.NameStore.names(pid)
    KOTL.NameStore.add(pid, %Location{type: :pid, name: :self, location: self})
    [%Location{type: :pid, name: :self, location: this}] = KOTL.NameStore.names(pid)
  end
end
