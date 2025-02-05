defmodule FatEcto.FatQuery.WhereOr do
  @moduledoc """
  This module provides functionality for constructing dynamic `where` or `where not` queries in Ecto.

  It includes aliases for `FatEcto.FatQuery.FatDynamics` and `FatEcto.FatQuery.FatNotDynamics` to simplify the usage of dynamic query generation.

  ## Examples

    # Example usage of FatDynamics
    FatDynamics.some_function(...)

    # Example usage of FatNotDynamics
    FatNotDynamics.some_function(...)
  """

  import Ecto.Query
  alias FatEcto.FatHelper
  alias FatEcto.FatQuery.FatDynamics
  alias FatEcto.FatQuery.FatNotDynamics

  @spec or_condition(any(), any(), any(), any()) :: any()
  def or_condition(queryable, nil, _build_options, _options), do: queryable

  def or_condition(queryable, where_map, _build_options, options) do
    dynamics =
      Enum.reduce(where_map, false, fn {k, map_cond}, dynamics ->
        map_condition(k, dynamics, map_cond, options)
      end)

    from(q in queryable, where: ^dynamics)
  end

  @spec map_condition(any(), any(), any(), any()) :: any()
  defp map_condition(k, dynamics, map_cond, opts) when is_map(map_cond) do
    Enum.reduce(map_cond, dynamics, fn {key, value}, dynamics ->
      field = FatHelper.string_to_existing_atom(k)

      case key do
        "$like" ->
          dynamics or FatDynamics.like_dynamic(field, value, opts)

        "$not_like" ->
          dynamics or FatNotDynamics.not_like_dynamic(field, value, opts)

        "$ilike" ->
          dynamics or FatDynamics.ilike_dynamic(field, value, opts)

        "$not_ilike" ->
          dynamics or FatNotDynamics.not_ilike_dynamic(field, value, opts)

        "$lt" ->
          dynamics or FatDynamics.lt_dynamic(field, value, opts)

        "$lte" ->
          dynamics or FatDynamics.lte_dynamic(field, value, opts)

        "$gt" ->
          dynamics or FatDynamics.gt_dynamic(field, value, opts)

        "$gte" ->
          dynamics or FatDynamics.gte_dynamic(field, value, opts)

        "$between" ->
          dynamics or FatDynamics.between_dynamic(field, value, opts)

        "$between_equal" ->
          dynamics or FatDynamics.between_equal_dynamic(field, value, opts)

        "$not_between" ->
          dynamics or FatNotDynamics.not_between_dynamic(field, value, opts)

        "$not_between_equal" ->
          dynamics or
            FatNotDynamics.not_between_equal_dynamic(field, value, opts)

        "$in" ->
          dynamics or FatDynamics.in_dynamic(field, value, opts)

        "$not_in" ->
          dynamics or FatNotDynamics.not_in_dynamic(field, value, opts)

        "$equal" ->
          dynamics or FatDynamics.eq_dynamic(field, value, opts)

        "$not_equal" ->
          dynamics or FatDynamics.not_eq_dynamic(field, value, opts)

        _ ->
          dynamics
      end
    end)
  end

  defp map_condition(k, dynamics, map_cond, opts) when is_nil(map_cond) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics or FatDynamics.nil_dynamic?(field, opts)
  end

  defp map_condition(k, dynamics, map_cond, opts)
      when map_cond == "$not_null" do
    field = FatHelper.string_to_existing_atom(k)
    dynamics or FatNotDynamics.not_nil_dynamic?(field, opts)
  end

  defp map_condition(k, dynamics, map_cond, opts) when not is_list(map_cond) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics or FatDynamics.eq_dynamic(field, map_cond, opts)
  end

  defp map_condition(k, dynamics, map_cond, opts)
      when is_list(map_cond) and k == "$not_null" do
    Enum.reduce(map_cond, dynamics, fn key, dynamics ->
      field = FatHelper.string_to_existing_atom(key)
      dynamics or FatNotDynamics.not_nil_dynamic?(field, opts)
    end)
  end

  defp map_condition(k, dynamics, map_cond, opts)
      when is_list(map_cond) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics or FatDynamics.eq_dynamic(field, map_cond, opts)
  end
end
