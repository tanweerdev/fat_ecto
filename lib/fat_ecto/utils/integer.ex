defmodule FatUtils.Integer do
  @moduledoc false
  def parse(int_str) do
    if is_integer(int_str) do
      {:ok, int_str}
    else
      case int_str && Integer.parse(int_str) do
        {integer, _} ->
          {:ok, integer}

        _whatever ->
          {:error, nil}
      end
    end
  end

  def parse!(int_str) do
    if is_integer(int_str) do
      int_str
    else
      case int_str && Integer.parse(int_str) do
        {integer, _} ->
          integer

        _whatever ->
          nil
      end
    end
  end
end
