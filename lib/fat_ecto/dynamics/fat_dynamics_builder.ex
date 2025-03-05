defmodule FatEcto.Dynamics.FatDynamicsBuilder do
  @moduledoc """
  This module builds Ecto dynamic queries from a JSON-like structure.
  It uses the `FatEcto.Dynamics.FatOperatorHelper` module to apply operators and construct the query.
  """

  import Ecto.Query
  alias FatEcto.Dynamics.FatOperatorHelper

  @doc """
  Builds an Ecto dynamic query from a JSON-like structure.

  ## Examples

      iex> import Ecto.Query
      ...> query = FatEcto.Dynamics.FatDynamicsBuilder.build(%{
      ...>   "$OR" => [
      ...>     %{"name" => "John"},
      ...>     %{"phone" => nil},
      ...>     %{"age" => %{"$GT" => 30}}
      ...>   ]
      ...> })
      iex> inspect(query)
      "dynamic([q], q.age > ^30 or (is_nil(q.phone) or q.name == ^\\\"John\\\"))"
  """
  @spec build(map(), keyword(), function() | nil) :: Ecto.Query.dynamic_expr()
  def build(query_map, opts \\ [], override_callback \\ nil) when is_map(query_map) do
    Enum.reduce(query_map, nil, fn {key, value}, dynamic_query ->
      case key do
        "$OR" ->
          build_or_query(value, dynamic_query, opts, override_callback)

        "$AND" ->
          build_and_query(value, dynamic_query, opts, override_callback)

        _ ->
          build_field_query(key, value, dynamic_query, opts, override_callback)
      end
    end)
  end

  # Handles "$OR" conditions
  defp build_or_query(conditions, dynamic_query, opts, override_callback) do
    or_dynamic =
      Enum.reduce(conditions, nil, fn condition, acc ->
        case acc do
          nil -> build(condition, opts, override_callback)
          _ -> dynamic([q], ^build(condition, opts, override_callback) or ^acc)
        end
      end)

    case {dynamic_query, or_dynamic} do
      {nil, _} -> or_dynamic
      {_, nil} -> dynamic_query
      _ -> dynamic([q], ^dynamic_query and ^or_dynamic)
    end
  end

  # Handles "$AND" conditions
  defp build_and_query(conditions, dynamic_query, opts, override_callback) do
    and_dynamic =
      Enum.reduce(conditions, nil, fn condition, acc ->
        case acc do
          nil -> build(condition, opts, override_callback)
          _ -> dynamic([q], ^build(condition, opts, override_callback) and ^acc)
        end
      end)

    case {dynamic_query, and_dynamic} do
      {nil, _} -> and_dynamic
      {_, nil} -> dynamic_query
      _ -> dynamic([q], ^dynamic_query and ^and_dynamic)
    end
  end

  # Handles individual field conditions
  defp build_field_query(field, conditions, dynamic_query, opts, override_callback) when is_map(conditions) do
    field_dynamic =
      Enum.reduce(conditions, nil, fn {operator, value}, acc ->
        case override_callback do
          nil ->
            # If no callback is provided, apply the standard operator logic
            case FatOperatorHelper.apply_operator(operator, field, value, opts) do
              nil -> acc
              operator_dynamic -> combine_dynamics(acc, operator_dynamic)
            end

          callback ->
            # If a callback is provided, use it to handle the field
            case callback.(acc, field, operator, value) do
              nil ->
                # If the callback returns nil, apply the standard operator logic
                case FatOperatorHelper.apply_operator(operator, field, value, opts) do
                  nil -> acc
                  operator_dynamic -> combine_dynamics(acc, operator_dynamic)
                end

              override_dynamic ->
                combine_dynamics(acc, override_dynamic)
            end
        end
      end)

    combine_dynamics(dynamic_query, field_dynamic)
  end

  # Handles direct field comparisons (e.g., "field" => "value" or "field" => nil)
  defp build_field_query(field, value, dynamic_query, opts, override_callback) do
    field_dynamic =
      case override_callback do
        nil ->
          # If no callback is provided, apply the standard operator logic
          case value do
            nil -> FatOperatorHelper.apply_nil_operator("$NULL", field, opts)
            _ -> FatOperatorHelper.apply_operator("$EQUAL", field, value, opts)
          end

        callback ->
          # If a callback is provided, use it to handle the field
          case callback.(dynamic_query, field, "$EQUAL", value) do
            nil ->
              # If the callback returns nil, apply the standard operator logic
              case value do
                nil -> FatOperatorHelper.apply_nil_operator("$NULL", field, opts)
                _ -> FatOperatorHelper.apply_operator("$EQUAL", field, value, opts)
              end

            override_dynamic ->
              override_dynamic
          end
      end

    combine_dynamics(dynamic_query, field_dynamic)
  end

  # Combines two dynamics, handling nil values
  defp combine_dynamics(dynamic1, dynamic2) do
    case {dynamic1, dynamic2} do
      {nil, _} -> dynamic2
      {_, nil} -> dynamic1
      _ -> dynamic([q], ^dynamic1 and ^dynamic2)
    end
  end
end
