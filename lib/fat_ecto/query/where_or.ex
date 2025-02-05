defmodule FatEcto.FatQuery.WhereOr do
  @moduledoc """
  This module provides functionality for constructing dynamic `where` or `where not` queries in Ecto.

  It allows you to build complex `OR` conditions dynamically based on a map of conditions.
  Each condition is processed and combined into a single `OR` dynamic query.

  ## Examples

      # Example usage with a map of conditions
      conditions = %{
        "name" => %{"$like" => "John%"},
        "age" => %{"$gte" => 18, "$lt" => 30}
      }

      query = FatEcto.FatQuery.WhereOr.or_condition(MySchema, conditions, [], [])

      # The resulting query will have an `OR` condition for the name and age fields.
  """

  import Ecto.Query
  alias FatEcto.FatHelper
  alias FatEcto.FatQuery.FatDynamics
  alias FatEcto.FatQuery.FatNotDynamics
  alias FatEcto.FatQuery.OperatorHelper

  @doc """
  Constructs a dynamic `OR` condition for the given queryable based on the provided `where_map`.

  If `where_map` is `nil`, the original queryable is returned unchanged.

  ## Parameters
  - `queryable`: The Ecto queryable to which the conditions will be applied.
  - `where_map`: A map of conditions. Each key represents a field, and the value is a map of operators and values.
  - `options`: Additional options for dynamic query generation (e.g., prefix, schema).

  ## Returns
  - The queryable with the dynamic `OR` conditions applied.
  """
  @spec or_condition(Ecto.Queryable.t(), map() | nil, keyword()) :: Ecto.Queryable.t()
  def or_condition(queryable, nil, _options), do: queryable

  def or_condition(queryable, where_map, options) do
    dynamics =
      Enum.reduce(where_map, false, fn {field, conditions}, dynamics ->
        map_condition(field, dynamics, conditions, options)
      end)

    from(q in queryable, where: ^dynamics)
  end

  @spec map_condition(String.t(), %Ecto.Query.DynamicExpr{}, map() | any(), keyword()) ::
          %Ecto.Query.DynamicExpr{}
  defp map_condition(field, dynamics, conditions, opts) when is_map(conditions) do
    Enum.reduce(conditions, dynamics, fn {operator, value}, dynamics ->
      field_atom = FatHelper.string_to_existing_atom(field)
      dynamics or (OperatorHelper.apply_operator(operator, field_atom, value, opts) || false)
    end)
  end

  defp map_condition(field, dynamics, nil, opts) do
    field_atom = FatHelper.string_to_existing_atom(field)
    dynamics or FatDynamics.nil_dynamic?(field_atom, opts)
  end

  defp map_condition(field, dynamics, "$not_null", opts) do
    field_atom = FatHelper.string_to_existing_atom(field)
    dynamics or FatNotDynamics.not_nil_dynamic?(field_atom, opts)
  end

  defp map_condition(field, dynamics, value, opts) when not is_list(value) do
    field_atom = FatHelper.string_to_existing_atom(field)
    dynamics or FatDynamics.eq_dynamic(field_atom, value, opts)
  end

  defp map_condition(field, dynamics, values, opts) when is_list(values) do
    if field == "$not_null" do
      Enum.reduce(values, dynamics, fn key, dynamics ->
        field_atom = FatHelper.string_to_existing_atom(key)
        dynamics or FatNotDynamics.not_nil_dynamic?(field_atom, opts)
      end)
    else
      field_atom = FatHelper.string_to_existing_atom(field)
      dynamics or FatDynamics.eq_dynamic(field_atom, values, opts)
    end
  end
end
