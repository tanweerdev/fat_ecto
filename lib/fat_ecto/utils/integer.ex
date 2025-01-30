defmodule FatUtils.Integer do
  @moduledoc """
    Parse integer from strings.
  """

  @doc """
    Parse integer from string and return result in the form of tuple.
  """
  @spec parse(any()) :: {:error, nil} | {:ok, any()}

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

  @doc """
    Parse integer from string and return result.
  """
  @spec parse!(any()) :: any()

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
