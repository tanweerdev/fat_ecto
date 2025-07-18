defmodule FatEcto.Query.Helper do
  @moduledoc """
  Provides helper functions for filtering and processing query parameters in `FatEcto.Query.Dynamics.Buildable`.
  """

  @doc """
  Removes fields with ignoreable values from the query parameters.

  ### Parameters
    - `where_params`: The query parameters (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
    - `ignoreable_fields_values`: A keyword list of fields and their ignoreable values (e.g., `[email: ["", "%%", nil], phone: [nil]]`).

  ### Returns
    - The filtered query parameters.
  """
  alias FatEcto.SharedHelper
  @spec remove_ignoreable_fields(map(), keyword() | map()) :: map()
  def remove_ignoreable_fields(where_params, ignoreable_fields_values) do
    ignoreable_fields_values = SharedHelper.keyword_list_to_map(ignoreable_fields_values)

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
    - `filterable_fields`: A keyword list of fields and their allowed operators (e.g., `[name: ["$EQUAL"], age: "*"]`).
    - `overrideable_fields`: A list of fields that can be overridden (e.g., `["phone"]`).

  ### Returns
    - The filtered query parameters.
  """
  @spec filter_filterable_fields(map(), keyword() | map(), [any()]) :: map()
  def filter_filterable_fields(where_params, filterable_fields, overrideable_fields) do
    filterable_fields = SharedHelper.filterable_opt_to_map(filterable_fields)
    do_filter_filterable_fields(where_params, filterable_fields, overrideable_fields, %{})
  end

  # Private helper method to process the input recursively
  defp do_filter_filterable_fields(params, filterable_fields, overrideable_fields, acc) when is_map(params) do
    Enum.reduce(params, acc, fn {field, value}, inner_acc ->
      # Handle "$OR" and "$AND" conditions recursively
      if field in ["$OR", "$AND"] do
        processed_conditions = process_conditions(value, filterable_fields, overrideable_fields)

        if Enum.empty?(processed_conditions) do
          inner_acc
        else
          Map.put(inner_acc, field, processed_conditions)
        end

        # Handle individual fields
      else
        case filter_field(field, value, filterable_fields, overrideable_fields) do
          {filtered_field, filtered_value} ->
            Map.put(inner_acc, filtered_field, filtered_value)

          nil ->
            inner_acc
        end
      end
    end)
  end

  # Private helper method to process conditions in "$OR" and "$AND"
  defp process_conditions(conditions, filterable_fields, overrideable_fields) when is_map(conditions) do
    # Handle direct map (e.g., "$OR" => %{"rating" => %{"$GT" => 18}})
    processed_map = do_filter_filterable_fields(conditions, filterable_fields, overrideable_fields, %{})

    if map_size(processed_map) > 0 do
      processed_map
    else
      %{}
    end
  end

  defp process_conditions(conditions, filterable_fields, overrideable_fields) do
    # Handle array (e.g., "$OR" => [%{"rating" => %{"$GT" => 18}}])
    conditions
    |> Enum.map(&do_filter_filterable_fields(&1, filterable_fields, overrideable_fields, %{}))
    |> Enum.reject(&(&1 == %{}))
  end

  # Private helper method to filter individual fields
  defp filter_field(field, value, filterable_fields, overrideable_fields) do
    cond do
      # Field is overrideable
      field in overrideable_fields ->
        {field, value}

      # Field is filterable
      Map.has_key?(filterable_fields, field) ->
        allowed_operators = Map.get(filterable_fields, field)

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
            {field, filtered_value}
          else
            nil
          end
        else
          # Handle direct comparisons (e.g., "field" => "value")
          if operator_allowed?("$EQUAL", allowed_operators) do
            {field, %{"$EQUAL" => value}}
          else
            nil
          end
        end

      # Field is neither filterable nor overrideable
      true ->
        nil
    end
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
end
