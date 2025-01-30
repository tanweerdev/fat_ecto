defmodule FatUtils.BasicLogger do
  @moduledoc """
    Logs error messages in case of failure or success on console.
  """
  require Logger

  @doc """
    Takes data and then logs the data information with title as a key and data as value on console.
  """
  @spec log_action_failed(any(), any(), any()) :: :ok
  @spec log_action_failed(any()) :: :ok
  @spec log_action_failed(any(), any()) :: :ok
  def log_action_failed(data, title \\ "details", _opts \\ []) do
    Logger.error("#{title} => data: ##{inspect(data)}")
  end

  @doc """
  Takes data and then logs the data information with title as a key and data as value on console.
  """

  @spec log_action_success(any(), any(), any()) :: :ok
  @spec log_action_success(any(), any()) :: :ok
  def log_action_success(data, title \\ "details", _opts \\ []) do
    Logger.debug("#{title} => data: ##{inspect(data)}")
  end
end
