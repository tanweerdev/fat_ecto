defmodule FatUtils.DateTime do
  @moduledoc """
  Provides utility functions for parsing and converting date-time values.

  This module handles parsing of date-time values from integers (Unix timestamps) and
  binary strings (ISO 8601 format).
  """

  @spec parse(any()) :: :error | {:ok, DateTime.t()}
  @doc """
  Parses a date-time value from an integer (Unix timestamp) or a binary string (ISO 8601 format).

  Returns `{:ok, DateTime.t()}` on success or `:error` on failure.
  """
  def parse(dtu) do
    case parse!(dtu) do
      nil -> :error
      datetime -> {:ok, datetime}
    end
  end

  @spec parse!(any()) :: nil | DateTime.t()
  @doc """
  Parses a date-time value from an integer (Unix timestamp) or a binary string (ISO 8601 format).

  Returns a `DateTime.t()` on success or `nil` on failure.
  """
  def parse!(dtu) do
    cond do
      is_integer(dtu) && valid_unix?(dtu) -> DateTime.from_unix!(dtu)
      is_integer(dtu) && valid_unix_ms?(dtu) -> DateTime.from_unix!(dtu, :microsecond)
      is_binary(dtu) && valid_iso8601?(dtu) -> parse_iso8601!(dtu)
      true -> nil
    end
  end

  # Helper functions

  defp valid_unix?(dtu) do
    match?({:ok, _}, DateTime.from_unix(dtu))
  end

  defp valid_unix_ms?(dtu) do
    match?({:ok, _}, DateTime.from_unix(dtu, :microsecond))
  end

  defp valid_iso8601?(dtu) do
    match?({:ok, _, _}, DateTime.from_iso8601(dtu))
  end

  defp parse_iso8601!(dtu) do
    case DateTime.from_iso8601(dtu) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end
end
