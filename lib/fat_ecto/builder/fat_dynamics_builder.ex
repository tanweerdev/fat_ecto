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
  @spec build(map(), function() | nil) :: Ecto.Query.dynamic_expr()
  def build(query_map, override_callback \\ nil) when is_map(query_map) do
    Enum.reduce(query_map, nil, fn {key, value}, dynamic_query ->
      case key do
        "$OR" ->
          build_or_query(value, dynamic_query, override_callback)

        "$AND" ->
          build_and_query(value, dynamic_query, override_callback)

        _ ->
          build_field_query(key, value, dynamic_query, override_callback)
      end
    end)
  end

  # Handles "$OR" conditions
  defp build_or_query(conditions, dynamic_query, override_callback) when is_map(conditions) do
    # Handle direct map (e.g., "$OR" => %{"rating" => %{"$GT" => 18}})
    or_dynamic =
      Enum.reduce(conditions, nil, fn {field, value}, acc ->
        field_dynamic = build_field_query(field, value, nil, override_callback)
        combine_dynamics(acc, field_dynamic, :or)
      end)

    combine_dynamics(dynamic_query, or_dynamic, :and)
  end

  defp build_or_query(conditions, dynamic_query, override_callback) do
    # Handle array (e.g., "$OR" => [%{"rating" => %{"$GT" => 18}}])
    conditions_list = ensure_list(conditions)

    or_dynamic =
      Enum.reduce(conditions_list, nil, fn condition, acc ->
        condition_dynamic = build(condition, override_callback)
        combine_dynamics(acc, condition_dynamic, :or)
      end)

    combine_dynamics(dynamic_query, or_dynamic, :and)
  end

  # Handles "$AND" conditions
  defp build_and_query(conditions, dynamic_query, override_callback) do
    conditions_list = ensure_list(conditions)

    and_dynamic =
      Enum.reduce(conditions_list, nil, fn condition, acc ->
        condition_dynamic = build(condition, override_callback)
        combine_dynamics(acc, condition_dynamic, :and)
      end)

    combine_dynamics(dynamic_query, and_dynamic, :and)
  end

  # Handles individual field conditions
  defp build_field_query(field, conditions, dynamic_query, override_callback) when is_map(conditions) do
    field_dynamic =
      Enum.reduce(conditions, nil, fn {operator, value}, acc ->
        case override_callback do
          nil ->
            # If no callback is provided, apply the standard operator logic
            case FatOperatorHelper.apply_operator(operator, field, value) do
              nil -> acc
              operator_dynamic -> combine_dynamics(acc, operator_dynamic, :and)
            end

          callback ->
            # If a callback is provided, use it to handle the field
            case callback.(acc, field, operator, value) do
              nil ->
                # If the callback returns nil, apply the standard operator logic
                case FatOperatorHelper.apply_operator(operator, field, value) do
                  nil -> acc
                  operator_dynamic -> combine_dynamics(acc, operator_dynamic, :and)
                end

              override_dynamic ->
                combine_dynamics(acc, override_dynamic, :and)
            end
        end
      end)

    combine_dynamics(dynamic_query, field_dynamic, :and)
  end

  # Handles direct field comparisons (e.g., "field" => "value" or "field" => nil)
  defp build_field_query(field, value, dynamic_query, override_callback) do
    field_dynamic =
      case override_callback do
        nil ->
          # If no callback is provided, apply the standard operator logic
          case value do
            nil -> FatOperatorHelper.apply_nil_operator("$NULL", field)
            _ -> FatOperatorHelper.apply_operator("$EQUAL", field, value)
          end

        callback ->
          # If a callback is provided, use it to handle the field
          case callback.(dynamic_query, field, "$EQUAL", value) do
            nil ->
              # If the callback returns nil, apply the standard operator logic
              case value do
                nil -> FatOperatorHelper.apply_nil_operator("$NULL", field)
                _ -> FatOperatorHelper.apply_operator("$EQUAL", field, value)
              end

            override_dynamic ->
              override_dynamic
          end
      end

    combine_dynamics(dynamic_query, field_dynamic, :and)
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
