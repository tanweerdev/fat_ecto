defmodule FatUtils.String do
  def random(length \\ 8) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64(padding: false) |> binary_part(0, length)
  end

  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("")

  def random_of(length, array_of_chars \\ @chars) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(array_of_chars) | acc]
    end)
    |> Enum.join("")
  end
end
