defmodule FatUtils.String do
  @moduledoc """
    Generate string with different number of characters.
  """

  @doc """
    Generate string of length 8 if length is not defined.
  """
  @spec random(non_neg_integer()) :: binary()
  def random(length \\ 8) do
    length |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false) |> binary_part(0, length)
  end

  @chars String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "")
  @doc """
    Generate string of specific length and also takes comma separated characters from which string is generated.
  """
  @spec random_of(integer(), any()) :: binary()

  def random_of(length, array_of_chars \\ @chars) do
    1..length
    |> Enum.reduce([], fn _i, acc ->
      [Enum.random(array_of_chars) | acc]
    end)
    |> Enum.join("")
  end
end
