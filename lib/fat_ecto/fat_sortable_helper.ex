defmodule FatEcto.FatSortableHelper do
  @moduledoc """
  Provides helper functions for sorting query parameters.
  """

  @doc """
  Filters sortable fields based on the provided `sortable_fields` map.

  ### Parameters
    - `filtered_params`: A map of fields and their sorting operators.
    - `sortable_fields`: A map of allowed fields and their corresponding operators.

  ### Returns
    - A filtered map containing only the fields and operators that are allowed.
  """
  @spec filter_sortable_fields(map(), map()) :: map()
  def filter_sortable_fields(filtered_params, sortable_fields) do
    Enum.reduce(filtered_params, %{}, fn {field, operator}, acc ->
      if Map.has_key?(sortable_fields, field) do
        allowed_operators = sortable_fields[field]

        case allowed_operators do
          "*" ->
            Map.put(acc, field, operator)

          allowed when is_binary(allowed) ->
            if allowed == operator, do: Map.put(acc, field, operator), else: acc

          allowed when is_list(allowed) ->
            if operator in allowed, do: Map.put(acc, field, operator), else: acc

          _ ->
            acc
        end
      else
        acc
      end
    end)
  end
end
