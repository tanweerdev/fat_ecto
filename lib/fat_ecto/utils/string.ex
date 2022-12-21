defmodule FatUtils.String do
  @moduledoc """
    Generate string with different number of characters.
  """

  @doc """
    Generate string of length 8 if length is not defined.
  """
  def random(length \\ 8) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64(padding: false) |> binary_part(0, length)
  end

  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("")
  @doc """
    Generate string of specific length and also takes comma separated characters from which string is generated.
  """
  def random_of(length, array_of_chars \\ @chars) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(array_of_chars) | acc]
    end)
    |> Enum.join("")
  end
end
