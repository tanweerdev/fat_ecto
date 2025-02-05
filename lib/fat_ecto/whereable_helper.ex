defmodule FatEcto.FatQuery.WhereableHelper do
  @moduledoc """
  Provides helper functions for filtering and processing query parameters.
  """

  @doc """
  Removes fields from `where_params` if their values match any of the values in `ignoreable_fields_values`.

  ## Parameters
  - where_params: A map containing the fields, operators, and values to filter.
  - ignoreable_fields_values: A map containing fields and their ignoreable values (can be a single value or a list of values).

  ## Returns
  A filtered map with ignoreable fields removed.
  """
  @spec remove_ignoreable_fields(map(), map()) :: map()
  def remove_ignoreable_fields(where_params, ignoreable_fields_values) do
    filter_ignoreable_map(where_params, ignoreable_fields_values)
  end

  # Recursively filters a map
  defp filter_ignoreable_map(map, ignoreable_fields_values) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      # Handle "$or" key (preserve structure)
      # TODO: Handle "$not" key and preserve structure
      if key == "$or" do
        filtered_or_value = filter_ignoreable_map(value, ignoreable_fields_values)
        if filtered_or_value != %{}, do: Map.put(acc, key, filtered_or_value), else: acc

        # Handle regular fields
      else
        case Map.get(ignoreable_fields_values, key) do
          nil ->
            # Field is not in ignoreable_fields_values, include it
            Map.put(acc, key, value)

          ignoreable_values ->
            # Field is in ignoreable_fields_values, filter its value
            filtered_value = filter_ignoreable_value(value, ignoreable_values)
            if filtered_value != %{}, do: Map.put(acc, key, filtered_value), else: acc
        end
      end
    end)
  end

  # Filters a value based on ignoreable values
  defp filter_ignoreable_value(value, ignoreable_values) when is_map(value) do
    Enum.reduce(value, %{}, fn {operator, operator_value}, acc ->
      if should_keep_ignoreable_value(operator_value, ignoreable_values) do
        Map.put(acc, operator, operator_value)
      else
        acc
      end
    end)
  end

  defp filter_ignoreable_value(value, ignoreable_values) do
    if should_keep_ignoreable_value(value, ignoreable_values), do: value, else: %{}
  end

  # Checks if a value should be kept (i.e., it is not in ignoreable_values)
  defp should_keep_ignoreable_value(value, ignoreable_values) do
    ignoreable_values =
      if is_list(ignoreable_values) do
        ignoreable_values
      else
        [ignoreable_values]
      end

    not Enum.any?(ignoreable_values, fn ignoreable_value ->
      value == ignoreable_value
    end)
  end

  @doc """
  Filters fields in `params` based on the provided `filterable_fields` map.

  ## Parameters
  - params: A map containing the fields, operators, and values to filter.
  - filterable_fields: A map containing allowed fields and their corresponding operators.

  ## Returns
  A filtered map containing only the fields and operators that are allowed.
  """
  @spec filter_filterable_fields(map(), map()) :: map()
  def filter_filterable_fields(params, filterable_fields) do
    filter_filterable_map(params, filterable_fields)
  end

  # Recursively filters a map
  defp filter_filterable_map(map, filterable_fields) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      cond do
        # Handle "$or" key (preserve structure)
        key == "$or" ->
          filtered_or_value = filter_filterable_map(value, filterable_fields)
          if filtered_or_value != %{}, do: Map.put(acc, key, filtered_or_value), else: acc

        # Handle regular fields
        Map.has_key?(filterable_fields, key) ->
          allowed_operators = Map.get(filterable_fields, key)
          filtered_value = filter_filterable_value(value, allowed_operators)
          if filtered_value != %{}, do: Map.put(acc, key, filtered_value), else: acc

        # Drop fields not in filterable_fields
        true ->
          acc
      end
    end)
  end

  # Filters a value based on allowed operators
  defp filter_filterable_value(value, allowed_operators) when is_map(value) do
    Enum.reduce(value, %{}, fn {operator, operator_value}, acc ->
      cond do
        allowed_operators == "*" ->
          Map.put(acc, operator, operator_value)

        is_list(allowed_operators) && operator in allowed_operators ->
          Map.put(acc, operator, operator_value)

        is_binary(allowed_operators) && operator == allowed_operators ->
          Map.put(acc, operator, operator_value)

        true ->
          acc
      end
    end)
  end

  defp filter_filterable_value(value, _allowed_operators), do: value

  @doc """
  Filters overrideable fields based on the provided `overrideable_fields` list and `ignoreable_fields_values`.

  ## Parameters
  - params: A map containing the fields, operators, and values to filter.
  - overrideable_fields: A list of fields that can be overridden.
  - ignoreable_fields_values: A map containing fields and their ignoreable values.

  ## Returns
  A list of maps containing filtered fields, operators, and values.
  """
  @spec filter_overrideable_fields(map(), list(), map()) :: list(map())
  def filter_overrideable_fields(params, overrideable_fields, ignoreable_fields_values) do
    Enum.reduce(params, [], fn {field, value}, acc ->
      if field in overrideable_fields do
        Enum.reduce(value, acc, fn {operator, value}, acc ->
          if ignoreable_value?(value, ignoreable_fields_values[field] || []) do
            acc
          else
            [%{field: field, operator: operator, value: value} | acc]
          end
        end)
      else
        acc
      end
    end)
  end

  # Checks if a value is ignoreable for a given ignoreable_values.
  defp ignoreable_value?(value, ignoreable_values) when is_list(ignoreable_values) do
    value in ignoreable_values
  end

  defp ignoreable_value?(value, ignoreable_value) when is_binary(ignoreable_value) do
    value == ignoreable_value
  end
end
