defmodule FatEcto.FatQuery.WhereOr do
  alias FatEcto.FatQuery.{FatDynamics, FatNotDynamics}
  import Ecto.Query
  alias FatEcto.FatHelper

  def or_condition(queryable, where_map) do
    dynamics =
      Enum.reduce(where_map, true, fn {k, map_cond}, dynamics ->
        map_condition(k, dynamics, map_cond)
      end)

    case dynamics do
      nil ->
        {queryable, where_map}

      true ->
        {queryable, where_map}

      _ ->
        where_map = FatHelper.sanitize_or_params(where_map)
        queryable = from(q in queryable, where: ^dynamics)
        {queryable, where_map}
    end
  end

  def map_condition(k, dynamics, map_cond) when is_map(map_cond) do
    Enum.reduce(map_cond, %{}, fn {key, value}, _map ->
      case key do
        "$or_like" ->
          FatDynamics.like_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_not_like" ->
          FatNotDynamics.not_like_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_ilike" ->
          FatDynamics.ilike_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_not_ilike" ->
          FatNotDynamics.not_ilike_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_lt" ->
          FatDynamics.lt_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_lte" ->
          FatDynamics.lte_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_gt" ->
          FatDynamics.gt_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_gte" ->
          FatDynamics.gte_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_between" ->
          FatDynamics.between_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_between_equal" ->
          FatDynamics.between_equal_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_not_between" ->
          FatNotDynamics.not_between_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_not_between_equal" ->
          FatNotDynamics.not_between_equal_dynamic(
            k,
            value,
            dynamics,
            dynamic_type: :or
          )

        "$or_in" ->
          FatDynamics.in_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_not_in" ->
          FatNotDynamics.not_in_dynamic(k, value, dynamics, dynamic_type: :or)

        "$or_equal" ->
          FatDynamics.eq_dynamic(k, value, dynamics, dynamic_type: :or)

        _ ->
          dynamics
      end
    end)
  end

  def map_condition(_k, _dynamics, _map_cond), do: nil
end
