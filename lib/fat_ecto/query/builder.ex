defmodule FatEcto.FatQuery.Builder do
  @moduledoc """
  This module builds Ecto dynamic queries from a JSON-like structure.
  It uses the `FatEcto.FatQuery.OperatorHelper` module to apply operators and construct the query.
  """

  import Ecto.Query
  alias FatEcto.FatQuery.OperatorHelper

  @doc """
  Builds an Ecto dynamic query from a JSON-like structure.

  ## Examples

      iex> import Ecto.Query
      ...> query = FatEcto.FatQuery.Builder.build_query(%{
      ...>   "$OR" => [
      ...>     %{"name" => "John"},
      ...>     %{"phone" => nil},
      ...>     %{"age" => %{"$GT" => 30}}
      ...>   ]
      ...> })
      iex> inspect(query)
      "dynamic([q], q.age > ^30 or (is_nil(q.phone) or q.name == ^\\\"John\\\"))"
  """
  @spec build_query(map(), keyword()) :: %Ecto.Query.DynamicExpr{}
  def build_query(query_map, opts \\ []) when is_map(query_map) do
    Enum.reduce(query_map, nil, fn {key, value}, dynamic_query ->
      case key do
        "$OR" ->
          build_or_query(value, dynamic_query, opts)

        "$AND" ->
          build_and_query(value, dynamic_query, opts)

        _ ->
          build_field_query(key, value, dynamic_query, opts)
      end
    end)
  end

  # Handles "$OR" conditions
  defp build_or_query(conditions, dynamic_query, opts) do
    or_dynamic =
      Enum.reduce(conditions, nil, fn condition, acc ->
        case acc do
          nil -> build_query(condition, opts)
          _ -> dynamic([q], ^build_query(condition, opts) or ^acc)
        end
      end)

    case {dynamic_query, or_dynamic} do
      {nil, _} -> or_dynamic
      {_, nil} -> dynamic_query
      _ -> dynamic([q], ^dynamic_query and ^or_dynamic)
    end
  end

  # Handles "$AND" conditions
  defp build_and_query(conditions, dynamic_query, opts) do
    and_dynamic =
      Enum.reduce(conditions, nil, fn condition, acc ->
        case acc do
          nil -> build_query(condition, opts)
          _ -> dynamic([q], ^build_query(condition, opts) and ^acc)
        end
      end)

    case {dynamic_query, and_dynamic} do
      {nil, _} -> and_dynamic
      {_, nil} -> dynamic_query
      _ -> dynamic([q], ^dynamic_query and ^and_dynamic)
    end
  end

  # Handles individual field conditions
  defp build_field_query(field, conditions, dynamic_query, opts) when is_map(conditions) do
    field_dynamic =
      Enum.reduce(conditions, nil, fn {operator, value}, acc ->
        case OperatorHelper.apply_operator(operator, field, value, opts) do
          nil ->
            acc

          operator_dynamic ->
            case acc do
              nil -> operator_dynamic
              _ -> dynamic([q], ^acc and ^operator_dynamic)
            end
        end
      end)

    case {dynamic_query, field_dynamic} do
      {nil, _} -> field_dynamic
      {_, nil} -> dynamic_query
      _ -> dynamic([q], ^dynamic_query and ^field_dynamic)
    end
  end

  # Handles direct field comparisons (e.g., "field" => "value" or "field" => nil)
  defp build_field_query(field, value, dynamic_query, opts) do
    field_dynamic =
      case value do
        nil -> OperatorHelper.apply_nil_operator("$NULL", field, opts)
        _ -> OperatorHelper.apply_operator("$EQUAL", field, value, opts)
      end

    case {dynamic_query, field_dynamic} do
      {nil, _} -> field_dynamic
      {_, nil} -> dynamic_query
      _ -> dynamic([q], ^dynamic_query and ^field_dynamic)
    end
  end
end
