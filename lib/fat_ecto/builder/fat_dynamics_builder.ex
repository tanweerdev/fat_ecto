defmodule FatEcto.Builder.FatDynamicsBuilder do
  @moduledoc """
  This module builds Ecto dynamic queries from a JSON-like structure.
  It uses the `FatEcto.Builder.FatOperatorHelper` module to apply operators and construct the query.
  """

  import Ecto.Query
  alias FatEcto.Builder.FatOperatorHelper

  @doc """
  Builds an Ecto dynamic query from a JSON-like structure.

  ## Examples

      iex> import Ecto.Query
      ...> query = FatEcto.Builder.FatDynamicsBuilder.build(%{
      ...>   "$OR" => [
      ...>     %{"name" => "John"},
      ...>     %{"phone" => nil},
      ...>     %{"age" => %{"$GT" => 30}}
      ...>   ]
      ...> })
      iex> inspect(query)
      "dynamic([q], q.name == ^\\\"John\\\" or is_nil(q.phone) or q.age > ^30)"
  """
  @spec build(map(), function() | nil, list() | nil) :: Ecto.Query.dynamic_expr()
  def build(query_map, override_callback \\ nil, overrideable_fields \\ nil) when is_map(query_map) do
    Enum.reduce(query_map, nil, fn {key, value}, dynamic_query ->
      case key do
        "$OR" ->
          build_or_query(value, dynamic_query, override_callback, overrideable_fields)

        "$AND" ->
          build_and_query(value, dynamic_query, override_callback, overrideable_fields)

        _ ->
          build_field_query(key, value, dynamic_query, override_callback, overrideable_fields)
      end
    end)
  end

  # Handles "$OR" conditions
  defp build_or_query(conditions, dynamic_query, override_callback, overrideable_fields)
       when is_map(conditions) do
    # Handle direct map (e.g., "$OR" => %{"rating" => %{"$GT" => 18}})
    or_dynamic =
      Enum.reduce(conditions, nil, fn {field, value}, acc ->
        field_dynamic = build_field_query(field, value, nil, override_callback, overrideable_fields)
        combine_dynamics(acc, field_dynamic, :or)
      end)

    combine_dynamics(dynamic_query, or_dynamic, :and)
  end

  defp build_or_query(conditions, dynamic_query, override_callback, overrideable_fields) do
    # Handle array (e.g., "$OR" => [%{"rating" => %{"$GT" => 18}}])
    conditions_list = ensure_list(conditions)

    or_dynamic =
      Enum.reduce(conditions_list, nil, fn condition, acc ->
        condition_dynamic = build(condition, override_callback, overrideable_fields)
        combine_dynamics(acc, condition_dynamic, :or)
      end)

    combine_dynamics(dynamic_query, or_dynamic, :and)
  end

  # Handles "$AND" conditions
  defp build_and_query(conditions, dynamic_query, override_callback, overrideable_fields) do
    conditions_list = ensure_list(conditions)

    and_dynamic =
      Enum.reduce(conditions_list, nil, fn condition, acc ->
        condition_dynamic = build(condition, override_callback, overrideable_fields)
        combine_dynamics(acc, condition_dynamic, :and)
      end)

    combine_dynamics(dynamic_query, and_dynamic, :and)
  end

  # Handles individual field conditions
  defp build_field_query(field, conditions, dynamic_query, override_callback, overrideable_fields)
       when is_map(conditions) do
    IO.inspect("field: #{inspect(field)}")
    IO.inspect("conditions: #{inspect(conditions)}")
    IO.inspect("dynamic_query: #{inspect(dynamic_query)}")
    IO.inspect("overrideable_fields: #{inspect(overrideable_fields)}")
    field_dynamic =
      Enum.reduce(conditions, nil, fn {operator, value}, acc ->
        # Call override if field is in filterable_fields or override_callback exists
        dynamic =
          if should_override?(field, operator, overrideable_fields) && override_callback do
            IO.inspect("override_callback: #{inspect(override_callback)}")
            IO.inspect("yesssss")
            override_callback.(acc, field, operator, value)
            # ||
            # FatOperatorHelper.apply_operator(operator, field, value)
          else
            FatOperatorHelper.apply_operator(operator, field, value)
          end

          # NOTE: this dynamic returned could actually be a query

        combine_dynamics(acc, dynamic, :and)
      end)

    combine_dynamics(dynamic_query, field_dynamic, :and)
  end

  # Handles direct field comparisons (e.g., "field" => "value" or "field" => nil)
  defp build_field_query(field, value, dynamic_query, override_callback, overrideable_fields) do
    # IO.inspect("value: #{inspect(value)}")
    operator = if is_nil(value), do: "$NULL", else: "$EQUAL"

    dynamic =
      if should_override?(field, operator, overrideable_fields) && override_callback do
        override_callback.(dynamic_query, field, operator, value) ||
          FatOperatorHelper.apply_operator(operator, field, value)
      else
        # IO.inspect("else:::")
        # IO.inspect("operator: #{inspect(operator)}")
        # IO.inspect("field: #{inspect(field)}")
        # IO.inspect("value: #{inspect(value)}")
        FatOperatorHelper.apply_operator(operator, field, value)
      end

    # IO.inspect("dynamic: #{inspect(dynamic)}")

    combine_dynamics(dynamic_query, dynamic, :and)
  end

  defp should_override?(field, _operator, overrideable_fields) do
    case overrideable_fields do
      nil -> true
      fields when is_list(fields) -> field in fields
      fields when is_map(fields) -> Map.has_key?(fields, field)
      _ -> true
    end
  end

  # Combines two dynamics with a specified operator (:and or :or)
  defp combine_dynamics(dynamic1, dynamic2, operator) do
    case {dynamic1, dynamic2} do
      {nil, _} ->
        dynamic2

      {_, nil} ->
        dynamic1

      _ ->
        case operator do
          :and -> dynamic([q], ^dynamic1 and ^dynamic2)
          :or -> dynamic([q], ^dynamic1 or ^dynamic2)
        end
    end
  end

  # Ensures the input is a list (converts maps to a list of one element)
  defp ensure_list(input) when is_map(input), do: [input]
  defp ensure_list(input) when is_list(input), do: input
  defp ensure_list(_), do: []
end
