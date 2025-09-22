defmodule FatEcto.Query.Builder do
  @moduledoc """
  Builds Ecto queries from a structured query map.
  Used by FatQueryBuildable for query building with query callbacks.
  """

  import Ecto.Query
  alias FatEcto.Query.OperatorApplier

  @spec build(Ecto.Queryable.t(), map(), function() | nil, list() | nil) :: Ecto.Query.t()
  def build(queryable, query_map, override_callback \\ nil, overrideable_fields \\ nil)
      when is_map(query_map) do
    Enum.reduce(query_map, from(q in queryable), fn {key, value}, query ->
      case key do
        "$OR" -> build_or_query(value, query, override_callback, overrideable_fields)
        "$AND" -> build_and_query(value, query, override_callback, overrideable_fields)
        _ -> build_field_query(key, value, query, override_callback, overrideable_fields)
      end
    end)
  end

  # Query-specific implementations
  defp build_or_query(conditions, query, callback, fields) when is_map(conditions) do
    or_query =
      Enum.reduce(conditions, nil, fn {field, value}, acc ->
        field_query = build_field_query(field, value, query, callback, fields)
        combine_queries(acc, field_query, :or)
      end)

    combine_queries(query, or_query, :and)
  end

  defp build_or_query(conditions, query, callback, fields) do
    conditions
    |> ensure_list()
    |> Enum.reduce(nil, fn condition, acc ->
      condition_query = build(query, condition, callback, fields)
      combine_queries(acc, condition_query, :or)
    end)
    |> combine_queries(query, :and)
  end

  defp build_and_query(conditions, query, callback, fields) do
    conditions
    |> ensure_list()
    |> Enum.reduce(query, fn condition, acc ->
      build(acc, condition, callback, fields)
    end)
  end

  defp build_field_query(field, conditions, query, callback, fields) when is_map(conditions) do
    Enum.reduce(conditions, query, fn {operator, value}, acc ->
      if should_override?(field, fields) && callback do
        callback.(acc, field, operator, value) ||
          apply_operator(acc, operator, field, value)
      else
        apply_operator(acc, operator, field, value)
      end
    end)
  end

  defp build_field_query(field, value, query, callback, fields) do
    operator = if is_nil(value), do: "$NULL", else: "$EQUAL"

    if should_override?(field, fields) && callback do
      callback.(query, field, operator, value) ||
        apply_operator(query, operator, field, value)
    else
      apply_operator(query, operator, field, value)
    end
  end

  defp apply_operator(query, operator, field, value) do
    dynamic = OperatorApplier.apply_operator(operator, field, value)
    from(q in query, where: ^dynamic)
  end

  defp combine_queries(q1, q2, op) do
    cond do
      is_nil(q1) ->
        q2

      is_nil(q2) ->
        q1

      true ->
        # Extract the where expressions from both queries
        dynamic1 = get_where_expr(q1)
        dynamic2 = get_where_expr(q2)

        # Combine them with the appropriate operator
        combined =
          case op do
            :and -> dynamic([q], ^dynamic1 and ^dynamic2)
            :or -> dynamic([q], ^dynamic1 or ^dynamic2)
          end

        # Apply the combined where to the first query
        from(q in q1, where: ^combined)
    end
  end

  defp get_where_expr(query) do
    case query do
      %{wheres: [%{expr: expr} | _]} -> expr
      _ -> true
    end
  end

  # Shared helpers
  defp should_override?(field, fields) do
    case fields do
      nil -> true
      fields when is_list(fields) -> field in fields
      fields when is_map(fields) -> Map.has_key?(fields, field)
      _ -> true
    end
  end

  defp ensure_list(input) when is_map(input), do: [input]
  defp ensure_list(input) when is_list(input), do: input
  defp ensure_list(_), do: []
end
