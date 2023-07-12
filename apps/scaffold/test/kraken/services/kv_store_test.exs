defmodule Scaffold.Services.StoreTest do
  use ExUnit.Case

  @kraken_folder Path.expand("../../../../lib/kraken", __ENV__.file)

  def read_definition(path) do
    File.read!("#{@kraken_folder}/#{path}")
  end

  setup do
    {:ok, "kv-store"} = Octopus.define(read_definition("services/kv-store.json"))
    {:ok, _state} = Octopus.start("kv-store")

    on_exit(fn -> Octopus.delete("kv-store") end)
  end

  test "set and get" do
    assert {:ok, %{"ok" => "ok"}} =
             Octopus.call("kv-store", "set", %{"key" => "foo", "value" => "bar"})

    assert {:ok, %{"value" => "bar"}} = Octopus.call("kv-store", "get", %{"key" => "foo"})
  end
end
