defmodule FatUtils.DateTime do
  @moduledoc false
  def to_date_time(dtu) do
    cond do
      is_integer(dtu) && ({:ok, _dt} = DateTime.from_unix(dtu)) ->
        {:ok, dt} = DateTime.from_unix(dtu)
        dt

      is_integer(dtu) && ({:ok, _dt} = DateTime.from_unix(dtu, :microsecond)) ->
        {:ok, dt} = DateTime.from_unix(dtu, :microsecond)
        dt

      is_binary(dtu) ->
        {:ok, datetime, _} = DateTime.from_iso8601(dtu)
        datetime

      true ->
        nil
    end
  end
end
