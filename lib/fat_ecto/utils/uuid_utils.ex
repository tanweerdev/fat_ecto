defmodule FatUtils.UUID do
  @moduledoc """
    Provides method that works on UUID
  """
  alias Ecto.UUID

  @doc """
    It will take parameters as list of uuid fields and return result.
  """

  # will return {invalid_uuids, params}
  @spec parse(map(), any(), any()) :: any()
  def parse(params, list_of_uuid_fields, options \\ []) when is_map(params) do
    Enum.reduce(params, {[], %{}}, fn {key, value}, acc ->
      if !(value in (options[:valid_values] || [])) && key in list_of_uuid_fields do
        case UUID.cast(value) do
          {:ok, _valid_uuid} ->
            {elem(acc, 0), Map.put(elem(acc, 1), key, value)}

          _whatever ->
            {elem(acc, 0) ++ [key], elem(acc, 1)}
        end
      else
        {elem(acc, 0), Map.put(elem(acc, 1), key, value)}
      end
    end)
  end
end
