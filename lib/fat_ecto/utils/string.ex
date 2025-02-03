defmodule FatUtils.String do
  @moduledoc """
  Provides utility functions for generating random strings.

  This module includes functions for generating random strings of specified lengths
  and from specific character sets.
  """

  @default_length 8
  @default_chars String.graphemes("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

  @doc """
  Generates a random string of the specified length.

  ## Parameters
  - `length`: The length of the random string (default: 8).

  ## Examples
      iex> FatUtils.String.random()
      "aB3dEfG1"

      iex> FatUtils.String.random(12)
      "xYz1aB2cD3eF"
  """
  @spec random(non_neg_integer()) :: binary()
  def random(length \\ @default_length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  @doc """
  Generates a random string of the specified length using a custom character set.

  ## Parameters
  - `length`: The length of the random string.
  - `char_set`: A list of characters to use for generating the string (default: A-Z).

  ## Examples
      iex> FatUtils.String.random_of(10)
      "ABCDEFGHIJ"

      iex> FatUtils.String.random_of(5, ["a", "b", "c"])
      "abcba"
  """
  @spec random_of(non_neg_integer(), list(String.t())) :: binary()
  def random_of(length, char_set \\ @default_chars) do
    char_set
    |> Enum.take_random(length)
    |> Enum.join()
  end
end
