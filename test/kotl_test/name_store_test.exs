defmodule KOTLTest.NameStoreTest do
  use ExUnit.Case
  doctest KOTL.NameStore

  test "basic functionality, name" do
    {:ok, _} = KOTL.NameStore.start_link
    %{} = KOTL.NameStore.names
    KOTL.NameStore.add(:own, self)
    this = self()
    %{own: ^this} = KOTL.NameStore.names
  end

  test "basic functionality, pid" do
    {:ok, pid} = KOTL.NameStore.start_link
    %{} = KOTL.NameStore.names(pid)
    KOTL.NameStore.add(pid, :own, self)
    this = self()
    %{own: ^this} = KOTL.NameStore.names(pid)
  end
end
