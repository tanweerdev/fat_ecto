defmodule FatUtils.DateTime do
  @moduledoc """
    Takes integer and binary values to convert them to proper DateTime format.
  """

  @doc """
    Takes date time in the form of integer to convert to unix format and also in binary format to convert to iso8601.
  """
  def parse(dtu) do
    cond do
      is_integer(dtu) && from_uni?(dtu) ->
        {:ok, dt} = DateTime.from_unix(dtu)
        dt

      is_integer(dtu) && from_uni_ms?(dtu) ->
        {:ok, dt} = DateTime.from_unix(dtu, :microsecond)
        dt

      is_binary(dtu) && from_iso8601?(dtu) ->
        {:ok, datetime, _} = DateTime.from_iso8601(dtu)
        datetime

      true ->
        nil
    end
  end

  defp from_uni?(dtu) do
    case DateTime.from_unix(dtu) do
      {:ok, _dt} -> true
      _other -> false
    end
  end

  defp from_uni_ms?(dtu) do
    case DateTime.from_unix(dtu, :microsecond) do
      {:ok, _dt} -> true
      _other -> false
    end
  end

  defp from_iso8601?(dtu) do
    case DateTime.from_iso8601(dtu) do
      {:ok, _datetime, _} -> true
      _other -> false
    end
  end
end
