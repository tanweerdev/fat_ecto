defmodule FatUtils.Network do
  @moduledoc """
  Provides utility functions for working with network-related tasks.

  This module includes functions for retrieving local network addresses.
  """

  @doc """
  Retrieves the local network address.

  ## Examples
      iex> FatUtils.Network.local_address()
      "192.168.1.100"

  ## Returns
  - A string representing the local network address, or `nil` if the address cannot be determined.
  """
  @spec local_address() :: String.t() | nil
  def local_address do
    case System.cmd("hostname", ["-I"]) do
      {ip_string, 0} ->
        ip_string
        |> String.trim()
        |> String.split()
        |> List.first()

      _ ->
        nil
    end
  end
end
