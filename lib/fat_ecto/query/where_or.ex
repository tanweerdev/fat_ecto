defmodule FatEcto.FatQuery.WhereOr do
  alias FatEcto.FatQuery.{FatDynamics, FatNotDynamics}
  import Ecto.Query
  def or_condition(queryable, nil), do: queryable

  def or_condition(queryable, where_map) do
    dynamics =
      Enum.reduce(where_map, true, fn {k, map_cond}, dynamics ->
        map_condition(k, dynamics, map_cond)
      end)

    from(q in queryable, where: ^dynamics)
  end

  def map_condition(k, dynamics, map_cond) when is_map(map_cond) do
    Enum.reduce(map_cond, %{}, fn {key, value}, _map ->
      case key do
        "$like" ->
          FatDynamics.like_dynamic(k, value, dynamics, dynamic_type: :or)

        "$not_like" ->
          FatNotDynamics.not_like_dynamic(k, value, dynamics, dynamic_type: :or)

        "$ilike" ->
          FatDynamics.ilike_dynamic(k, value, dynamics, dynamic_type: :or)

        "$not_ilike" ->
          FatNotDynamics.not_ilike_dynamic(k, value, dynamics, dynamic_type: :or)

        "$lt" ->
          FatDynamics.lt_dynamic(k, value, dynamics, dynamic_type: :or)

        "$lte" ->
          FatDynamics.lte_dynamic(k, value, dynamics, dynamic_type: :or)

        "$gt" ->
          FatDynamics.gt_dynamic(k, value, dynamics, dynamic_type: :or)

        "$gte" ->
          FatDynamics.gte_dynamic(k, value, dynamics, dynamic_type: :or)

        "$between" ->
          FatDynamics.between_dynamic(k, value, dynamics, dynamic_type: :or)

        "$between_equal" ->
          FatDynamics.between_equal_dynamic(k, value, dynamics, dynamic_type: :or)

        "$not_between" ->
          FatNotDynamics.not_between_dynamic(k, value, dynamics, dynamic_type: :or)

        "$not_between_equal" ->
          FatNotDynamics.not_between_equal_dynamic(
            k,
            value,
            dynamics,
            dynamic_type: :or
          )

        "$in" ->
          FatDynamics.in_dynamic(k, value, dynamics, dynamic_type: :or)

        "$not_in" ->
          FatNotDynamics.not_in_dynamic(k, value, dynamics, dynamic_type: :or)

        "$equal" ->
          FatDynamics.eq_dynamic(k, value, dynamics, dynamic_type: :or)

        _ ->
          dynamics
      end
    end)
  end
end
