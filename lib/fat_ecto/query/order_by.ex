defmodule FatEcto.FatQuery.FatOrderBy do
  @moduledoc """
  Builds query with `asc` or `desc` order.

  This module provides functionality to dynamically add `order_by` clauses to Ecto queries
  based on the provided parameters. It supports various order formats, including `$asc`,
  `$desc`, and nulls handling (`$asc_nulls_first`, `$desc_nulls_last`, etc.).
  """

  import Ecto.Query
  alias FatEcto.FatHelper

  @spec build_order_by(any(), any(), any(), any()) :: any()
  def build_order_by(queryable, order_by_params, _build_options, opts \\ [])

  def build_order_by(queryable, nil, _build_options, _opts) do
    queryable
  end

  @doc """
  Orders the results based on the `order_by` clause in the params.

  ### Parameters
    - `queryable`: Ecto Queryable that represents your schema name, table name, or query.
    - `order_by_params`: A map of fields and their order formats (e.g., `%{"field" => "$asc"}`).
    - `opts`: Options related to query bindings.
    - `build_options`: Options related to the OTP app (unused in this function).

  ### Examples
      iex> query_opts = %{"$order" => %{"id" => "$asc"}}
      iex> FatEcto.FatQuery.FatOrderBy.build_order_by(FatEcto.FatHospital, query_opts["$order"], [], [])
      #Ecto.Query<from f0 in FatEcto.FatHospital, order_by: [asc: f0.id]>
  """
  def build_order_by(queryable, order_by_params, _build_options, opts) do
    Enum.reduce(order_by_params, queryable, fn {field, format}, queryable ->
      field_atom = FatHelper.string_to_existing_atom(field)
      apply_order(queryable, field_atom, format, opts[:binding])
    end)
  end

  # Helper function to apply the order clause to the query
  defp apply_order(queryable, field, format, binding) do
    case binding do
      :last ->
        case format do
          "$desc" ->
            from([q, ..., c] in queryable, order_by: [desc: field(c, ^field)])

          "$asc" ->
            from([q, ..., c] in queryable, order_by: [asc: field(c, ^field)])

          "$asc_nulls_first" ->
            from([q, ..., c] in queryable, order_by: [asc_nulls_first: field(c, ^field)])

          "$asc_nulls_last" ->
            from([q, ..., c] in queryable, order_by: [asc_nulls_last: field(c, ^field)])

          "$desc_nulls_first" ->
            from([q, ..., c] in queryable, order_by: [desc_nulls_first: field(c, ^field)])

          "$desc_nulls_last" ->
            from([q, ..., c] in queryable, order_by: [desc_nulls_last: field(c, ^field)])

          # Handle unexpected formats gracefully
          _ ->
            queryable
        end

      _ ->
        case format do
          "$desc" -> from(queryable, order_by: [desc: ^field])
          "$asc" -> from(queryable, order_by: [asc: ^field])
          "$asc_nulls_first" -> from(queryable, order_by: [asc_nulls_first: ^field])
          "$asc_nulls_last" -> from(queryable, order_by: [asc_nulls_last: ^field])
          "$desc_nulls_first" -> from(queryable, order_by: [desc_nulls_first: ^field])
          "$desc_nulls_last" -> from(queryable, order_by: [desc_nulls_last: ^field])
          # Handle unexpected formats gracefully
          _ -> queryable
        end
    end
  end
end
