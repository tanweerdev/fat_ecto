defmodule FatEcto.Utils.Integer do
  @moduledoc """
  Provides utility functions for parsing integers from strings.

  This module handles parsing of integers from strings and ensures consistent return types.
  """

  @doc """
  Parses an integer from a string or returns the integer if already an integer.

  Returns `{:ok, integer}` on success or `{:error, nil}` on failure.
  """
  @spec parse(any()) :: {:ok, integer()} | {:error, nil}
  def parse(int_str) do
    case parse!(int_str) do
      nil -> {:error, nil}
      integer -> {:ok, integer}
    end
  end

  @doc """
  Parses an integer from a string or returns the integer if already an integer.

  Returns the parsed integer on success or `nil` on failure.
  """
  @spec parse!(any()) :: integer() | nil
  def parse!(int_str) do
    cond do
      is_integer(int_str) -> int_str
      is_binary(int_str) -> parse_integer(int_str)
      true -> nil
    end
  end

  # Helper function to parse an integer from a string
  defp parse_integer(int_str) do
    case Integer.parse(int_str) do
      {integer, _} -> integer
      :error -> nil
    end
  end
end
