defmodule FatEcto.FatQuery.FatAggregate do
  @moduledoc false
  # TODO: Add docs and examples for ex_doc
  import Ecto.Query
  alias FatEcto.FatHelper
  # use FatEcto.FatQuery.FatMaximum
  # use FatEcto.FatQuery.FatMinimum
  # use FatEcto.FatQuery.FatAverage
  # use FatEcto.FatQuery.FatCount

  # TODO: Add docs and examples for ex_doc
  # $aggregate: {
  #   "$count" : "score"
  #   "$avg": ["total_marks", "rating"]
  # }
  @doc false
  def build_aggregate(queryable, nil) do
    queryable
  end

  def build_aggregate(queryable, aggregate_params) do
    Enum.reduce(aggregate_params, queryable, fn {aggregate_type, fields}, queryable ->
      case aggregate_type do
        "$max" ->
          case fields do
            fields when is_list(fields) ->
              Enum.reduce(fields, queryable, fn field, queryable ->
                build_max(queryable, field)
              end)

            field when is_binary(field) ->
              build_max(queryable, field)
          end

        "$min" ->
          case fields do
            fields when is_list(fields) ->
              Enum.reduce(fields, queryable, fn field, queryable ->
                build_min(queryable, field)
              end)

            field when is_binary(field) ->
              build_min(queryable, field)
          end

        "$avg" ->
          case fields do
            fields when is_list(fields) ->
              Enum.reduce(fields, queryable, fn field, queryable ->
                build_avg(queryable, field)
              end)

            field when is_binary(field) ->
              build_avg(queryable, field)
          end

        "$count" ->
          case fields do
            fields when is_list(fields) ->
              Enum.reduce(fields, queryable, fn field, queryable ->
                build_count(queryable, field)
              end)

            field when is_binary(field) ->
              build_count(queryable, field)
          end

        "$count_distinct" ->
          case fields do
            fields when is_list(fields) ->
              Enum.reduce(fields, queryable, fn field, queryable ->
                build_count_distinct(queryable, field)
              end)

            field when is_binary(field) ->
              build_count_distinct(queryable, field)
          end

        "$sum" ->
          case fields do
            fields when is_list(fields) ->
              Enum.reduce(fields, queryable, fn field, queryable ->
                build_sum(queryable, field)
              end)

            field when is_binary(field) ->
              build_sum(queryable, field)
          end
      end
    end)
  end

  defp build_max(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{
        "$aggregate": %{"$max": %{^field => max(field(q, ^atom_field))}}
      }
    )
  end

  defp build_min(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{"$aggregate": %{"$min": %{^field => min(field(q, ^atom_field))}}}
    )
  end

  defp build_avg(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{"$aggregate": %{"$avg": %{^field => avg(field(q, ^atom_field))}}}
    )
  end

  defp build_count(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{"$aggregate": %{"$count": %{^field => count(field(q, ^atom_field))}}}
    )
  end

  defp build_count_distinct(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{
        "$aggregate": %{"$count_distinct": %{^field => count(field(q, ^atom_field), :distinct)}}
      }
    )
  end

  defp build_sum(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{"$aggregate": %{"$sum": %{^field => sum(field(q, ^atom_field))}}}
    )
  end
end
