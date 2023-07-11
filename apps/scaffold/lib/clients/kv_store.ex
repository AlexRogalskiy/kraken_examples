defmodule Scaffold.Clients.KVStore do
  @moduledoc """
  Simple key-value storage based on Agent.
  """

  @spec start(map(), map(), atom()) :: {:ok, map()} | {:error, :already_started}
  def start(%{}, %{}, service_module) do
    case Agent.start_link(fn -> %{} end, name: service_module) do
      {:ok, pid} ->
        {:ok, %{pid: pid, name: service_module}}

      {:error, {:already_started, _pid}} ->
        {:error, :already_started}
    end
  end

  @spec call(map(), map(), any()) :: {:ok, map()} | {:error, any()}
  def call(args, %{}, state) do
    operation = args["operation"]

    with :ok <- validate_operation(operation, args),
         {:ok, result} <- call_operation(operation, args, state) do
      {:ok, result}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  @spec stop(map(), map(), any()) :: :ok | nil
  def stop(%{}, %{}, state) do
    if Process.alive?(state.pid), do: Agent.stop(state.pid)
  end

  defp validate_operation("set", %{"key" => _, "value" => _}), do: :ok
  defp validate_operation("get", %{"key" => _}), do: :ok

  defp validate_operation(_unknown_operation, _args) do
    {:error, :invalid_operation_or_missing_arguments}
  end

  defp call_operation("set", %{"key" => key, "value" => value}, %{pid: pid}) do
    :ok = Agent.update(pid, &Map.put(&1, key, value))
    {:ok, "ok"}
  end

  defp call_operation("get", %{"key" => key}, %{pid: pid}) do
    value = Agent.get(pid, &Map.get(&1, key))
    {:ok, value}
  end
end
