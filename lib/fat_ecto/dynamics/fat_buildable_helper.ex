defmodule FatEcto.Dynamics.FatBuildableHelper do
  @moduledoc """
  Provides helper functions for filtering and processing query parameters in `FatEcto.Dynamics.FatBuildable`.
  """

  @doc """
  Removes fields with ignoreable values from the query parameters.

  ### Parameters
    - `where_params`: The query parameters (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
    - `ignoreable_fields_values`: A map of fields and their ignoreable values (e.g., `%{"email" => ["%%", "", [], nil]}`).

  ### Returns
    - The filtered query parameters.
  """
  @spec remove_ignoreable_fields(map(), map()) :: map()
  def remove_ignoreable_fields(where_params, ignoreable_fields_values) do
    Enum.reduce(where_params, %{}, fn {field, value}, acc ->
      case Map.get(ignoreable_fields_values, field) do
        nil ->
          # Field is not in ignoreable_fields_values, so keep it
          Map.put(acc, field, value)

        ignoreable_values ->
          if is_map(value) do
            # Handle nested operators (e.g., %{"$ILIKE" => "%123%"})
            filtered_value =
              Enum.reduce(value, %{}, fn {operator, val}, inner_acc ->
                if should_ignore_value?(val, ignoreable_values) do
                  inner_acc
                else
                  Map.put(inner_acc, operator, val)
                end
              end)

            if map_size(filtered_value) > 0 do
              Map.put(acc, field, filtered_value)
            else
              acc
            end
          else
            # Handle direct comparisons (e.g., "field" => "value")
            if should_ignore_value?(value, ignoreable_values) do
              acc
            else
              Map.put(acc, field, value)
            end
          end
      end
    end)
  end

  @doc """
  Filters fields based on the `filterable_fields` configuration.

  ### Parameters
    - `where_params`: The query parameters (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
    - `filterable_fields`: A map of fields and their allowed operators (e.g., `%{"email" => ["$EQUAL", "$LIKE"]}`).

  ### Returns
    - The filtered query parameters.
  """
  @spec filter_filterable_fields(map(), map()) :: map()
  def filter_filterable_fields(where_params, filterable_fields) do
    Enum.reduce(where_params, %{}, fn {field, value}, acc ->
      case Map.get(filterable_fields, field) do
        nil ->
          # Field is not in filterable_fields, so ignore it
          acc

        allowed_operators ->
          if is_map(value) do
            # Handle nested operators (e.g., %{"$EQUAL" => "value"})
            filtered_value =
              Enum.reduce(value, %{}, fn {operator, val}, inner_acc ->
                if operator_allowed?(operator, allowed_operators) do
                  Map.put(inner_acc, operator, val)
                else
                  inner_acc
                end
              end)

            if map_size(filtered_value) > 0 do
              Map.put(acc, field, filtered_value)
            else
              acc
            end
          else
            # Handle direct comparisons (e.g., "field" => "value")
            if operator_allowed?("$EQUAL", allowed_operators) do
              Map.put(acc, field, %{"$EQUAL" => value})
            else
              acc
            end
          end
      end
    end)
  end

  @doc """
  Filters fields based on the `overrideable_fields` configuration.

  ### Parameters
    - `where_params`: The query parameters (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
    - `overrideable_fields`: A list of fields that can be overridden (e.g., `["phone"]`).
    - `ignoreable_fields_values`: A map of fields and their ignoreable values (e.g., `%{"phone" => ["%%", "", [], nil]}`).

  ### Returns
    - A list of maps containing the field, operator, and value for overrideable fields.
  """
  @spec filter_overrideable_fields(map(), list(), map()) :: list(map())
  def filter_overrideable_fields(where_params, overrideable_fields, ignoreable_fields_values) do
    Enum.reduce(where_params, [], fn {field, value}, acc ->
      if field in overrideable_fields do
        case Map.get(ignoreable_fields_values, field) do
          nil ->
            # Field is not in ignoreable_fields_values, so process it
            process_overrideable_field(field, value, acc)

          ignoreable_values ->
            if is_map(value) do
              # Handle nested operators (e.g., %{"$EQUAL" => "value"})
              Enum.reduce(value, acc, fn {operator, val}, inner_acc ->
                if should_ignore_value?(val, ignoreable_values) do
                  inner_acc
                else
                  [%{field: field, operator: operator, value: val} | inner_acc]
                end
              end)
            else
              # Handle direct comparisons (e.g., "field" => "value")
              if should_ignore_value?(value, ignoreable_values) do
                acc
              else
                [%{field: field, operator: "$EQUAL", value: value} | acc]
              end
            end
        end
      else
        acc
      end
    end)
  end

  # Checks if a value should be ignored based on the ignoreable values.
  defp should_ignore_value?(value, ignoreable_values) when is_list(ignoreable_values) do
    Enum.any?(ignoreable_values, fn ignoreable_value ->
      value == ignoreable_value
    end)
  end

  defp should_ignore_value?(value, ignoreable_value) do
    value == ignoreable_value
  end

  # Checks if an operator is allowed for a field.
  defp operator_allowed?(operator, allowed_operators) when is_list(allowed_operators) do
    operator in allowed_operators
  end

  defp operator_allowed?(operator, allowed_operator) when is_binary(allowed_operator) do
    allowed_operator == "*" or operator == allowed_operator
  end

  defp operator_allowed?(_operator, _allowed_operators) do
    false
  end

  # Processes an overrideable field and adds it to the accumulator.
  defp process_overrideable_field(field, value, acc) do
    if is_map(value) do
      Enum.reduce(value, acc, fn {operator, val}, inner_acc ->
        [%{field: field, operator: operator, value: val} | inner_acc]
      end)
    else
      [%{field: field, operator: "$EQUAL", value: value} | acc]
    end
  end
end
