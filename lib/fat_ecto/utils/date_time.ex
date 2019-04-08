defmodule FatUtils.DateTime do
  @moduledoc """
    Takes integer and binary values to convert them to proper DateTime format.
  """

  @doc """
    Takes date time in the form of integer to convert to unix format and also in binary format to convert to iso8601.
  """
  def to_date_time(dtu) do
    cond do
      is_integer(dtu) ->
        case DateTime.from_unix(dtu) do
          {:error, _} ->
            {:ok, dt} = DateTime.from_unix(dtu, :microsecond)
            dt

          {:ok, dt} ->
            dt
        end

      is_binary(dtu) ->
        {:ok, datetime, _} = DateTime.from_iso8601(dtu)
        datetime

      true ->
        nil
    end
  end
end
