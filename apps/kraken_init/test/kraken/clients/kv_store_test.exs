defmodule KrakenInit.Clients.KVStoreTest do
  use ExUnit.Case
  alias KrakenInit.Kraken.Clients.KVStore

  describe "start/1" do
    setup do
      {:ok, state} = KVStore.start(%{}, %{}, MyService)
      %{state: state}
    end

    test "check state and data", %{state: state} do
      assert %{name: MyService, pid: _pid} = state
      assert Agent.get(state.name, fn map -> map end) == %{}
    end

    test "when already started" do
      assert {:error, :already_started} = KVStore.start(%{}, %{}, MyService)
    end

    test "start another service" do
      {:ok, state} = KVStore.start(%{}, %{}, AnotherService)

      assert Agent.get(state.name, fn map -> map end) == %{}
    end
  end

  describe "call" do
    setup do
      {:ok, state} = KVStore.start(%{}, %{}, MyService)
      on_exit(fn -> KVStore.stop(%{}, %{}, state) end)
      %{state: state}
    end

    test "set and get", %{state: state} do
      args = %{"operation" => "set", "key" => "foo", "value" => "bar"}
      assert {:ok, "ok"} = KVStore.call(args, %{}, state)

      args = %{"operation" => "get", "key" => "foo"}
      assert {:ok, "bar"} = KVStore.call(args, %{}, state)
    end

    test "invalid_operation_or_missing_arguments", %{state: state} do
      assert {:error, :invalid_operation_or_missing_arguments} =
               KVStore.call(%{"operation" => "invalid"}, %{}, state)

      assert {:error, :invalid_operation_or_missing_arguments} =
               KVStore.call(%{"operation" => "get"}, %{}, state)

      assert {:error, :invalid_operation_or_missing_arguments} =
               KVStore.call(
                 %{"operation" => "getset", "key" => "foo"},
                 %{},
                 state
               )

      assert {:error, :invalid_operation_or_missing_arguments} =
               KVStore.call(%{"operation" => "set", "key" => "foo"}, %{}, state)
    end
  end
end
