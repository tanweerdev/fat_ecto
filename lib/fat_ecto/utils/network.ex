defmodule FatUtils.Network do
  @moduledoc """
  Documentation for `FatUtils.Network`.
  """

  @doc """
  Gives you local network address.

  ## Examples

      iex> FatUtils.Network.ubuntu_network_address()
      :world

  """
  @spec ubuntu_network_address() :: any()
  def ubuntu_network_address do
    {ip_string, 0} = System.cmd("hostname", ["-I"])
    List.first(String.split(ip_string))
  end
end
