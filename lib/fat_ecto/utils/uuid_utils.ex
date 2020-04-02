defmodule FatUtils.UUID do
  # TODO: add docs
  # will return {invalid_uuids, params}
  def parse(params, list_of_uuid_fields) when is_map(params) do
    Enum.reduce(params, {[], %{}}, fn {key, value}, acc ->
      if key in list_of_uuid_fields do
        case Ecto.UUID.cast(value) do
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
