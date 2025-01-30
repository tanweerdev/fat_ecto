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
  alias FatEcto.FatQuery.{FatDynamics, FatNotDynamics}

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
  def map_condition(k, dynamics, map_cond, opts) when is_map(map_cond) do
    Enum.reduce(map_cond, dynamics, fn {key, value}, dynamics ->
      case key do
        "$like" ->
          FatDynamics.like_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$not_like" ->
          FatNotDynamics.not_like_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$ilike" ->
          FatDynamics.ilike_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$not_ilike" ->
          FatNotDynamics.not_ilike_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$lt" ->
          FatDynamics.lt_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$lte" ->
          FatDynamics.lte_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$gt" ->
          FatDynamics.gt_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$gte" ->
          FatDynamics.gte_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$between" ->
          FatDynamics.between_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$between_equal" ->
          FatDynamics.between_equal_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$not_between" ->
          FatNotDynamics.not_between_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$not_between_equal" ->
          FatNotDynamics.not_between_equal_dynamic(
            k,
            value,
            dynamics,
            opts ++ [dynamic_type: :or]
          )

        "$in" ->
          FatDynamics.in_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$not_in" ->
          FatNotDynamics.not_in_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$equal" ->
          FatDynamics.eq_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        "$not_equal" ->
          FatDynamics.not_eq_dynamic(k, value, dynamics, opts ++ [dynamic_type: :or])

        _ ->
          dynamics
      end
    end)
  end

  def map_condition(k, dynamics, map_cond, opts) when is_nil(map_cond) do
    FatDynamics.nil_dynamic?(k, dynamics, opts ++ [dynamic_type: :or])
  end

  def map_condition(k, dynamics, map_cond, opts)
      when map_cond == "$not_null" do
    FatNotDynamics.not_nil_dynamic?(k, dynamics, opts ++ [dynamic_type: :or])
  end

  def map_condition(k, dynamics, map_cond, opts) when not is_list(map_cond) do
    FatDynamics.eq_dynamic(k, map_cond, dynamics, opts ++ [dynamic_type: :or])
  end

  def map_condition(k, dynamics, map_cond, opts)
      when is_list(map_cond) and k == "$not_null" do
    Enum.reduce(map_cond, dynamics, fn key, dynamics ->
      FatNotDynamics.not_nil_dynamic?(key, dynamics, opts ++ [dynamic_type: :or])
    end)
  end

  def map_condition(k, dynamics, map_cond, opts)
      when is_list(map_cond) do
    FatDynamics.eq_dynamic(k, map_cond, dynamics, opts ++ [dynamic_type: :or])
  end
end
