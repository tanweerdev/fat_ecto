defmodule FatUtils.Map do
  def has_all_keys?(map, keys) do
    Enum.all?(keys, fn key -> Map.has_key?(map, key) end)
  end

  def has_all_val_equal_to?(map, keys, equal_to) do
    Enum.all?(keys, fn key -> Map.get(map, key) == equal_to end)
  end

  def has_any_of_keys?(map, keys) do
    Enum.any?(keys, fn key -> Map.has_key?(map, key) end)
  end

  def deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  defp deep_resolve(_key, %{} = left, %{} = right) do
    deep_merge(left, right)
  end

  defp deep_resolve(_key, _left, right) do
    right
  end

  def sanitize_map(records) when is_list(records) do
    Enum.reduce(records, [], fn rec, acc ->
      acc ++ [sanitize_map(rec)]
    end)
  end

  def sanitize_map(record) when is_tuple(record) do
    case tuple_size(record) do
      2 ->
        [key, value] = Tuple.to_list(record)
        %{key => sanitize_map(value)}

      _size ->
        record
        |> Tuple.to_list()
        |> Jason.Encoder.List.encode([])
    end
  end

  def sanitize_map(record) when is_map(record) do
    schema_keys = [:__struct__, :__meta__]

    Enum.reduce(Map.drop(record, schema_keys), %{}, fn {k, v}, acc ->
      cond do
        is_list(v) && List.first(v) && is_map(List.first(v)) &&
            Enum.all?(schema_keys, &Map.has_key?(List.first(v), &1)) ->
          values =
            Enum.reduce(v, [], fn rec, acc ->
              acc ++ [sanitize_map(rec)]
            end)

          Map.put(acc, k, values)

        (is_map(v) && Map.has_key?(v, :__struct__) && Ecto.assoc_loaded?(v)) || !is_map(v) ->
          Map.put(
            acc,
            k,
            if(
              is_map(v) && Enum.all?(schema_keys, &Map.has_key?(v, &1)),
              do: sanitize_map(v),
              else: v
            )
          )

        true ->
          acc
      end
    end)
  end

  def sanitize_map(record) do
    record
  end
end
