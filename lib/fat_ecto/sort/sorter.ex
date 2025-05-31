defmodule FatEcto.Sort.Sorter do
  @moduledoc """
  Builds query with `asc` or `desc` order.

  This module provides functionality to dynamically add `order_by` clauses to Ecto queries
  based on the provided parameters. It supports various order formats, including `$ASC`,
  `$DESC`, and nulls handling (`$ASC_NULLS_FIRST`, `$DESC_NULLS_LAST`, etc.).
  """

  import Ecto.Query
  alias FatEcto.SharedHelper

  @spec build_order_by(any(), any(), any(), any()) :: any()
  def build_order_by(queryable, order_by_params, _build_options, opts \\ [])

  def build_order_by(queryable, nil, _build_options, _opts) do
    queryable
  end

  @doc """
  Orders the results based on the `order_by` clause in the params.

  ### Parameters
    - `queryable`: Ecto Queryable that represents your schema name, table name, or query.
    - `order_by_params`: A map of fields and their order formats (e.g., `%{"field" => "$ASC"}`).
    - `opts`: Options related to query bindings.
    - `build_options`: Options related to the OTP app (unused in this function).

  ### Examples
      iex> query_opts = %{"$ORder" => %{"id" => "$ASC"}}
      iex> FatEcto.Sort.Sorter.build_order_by(FatEcto.FatHospital, query_opts["$ORder"], [], [])
      #Ecto.Query<from f0 in FatEcto.FatHospital, order_by: [asc: f0.id]>
  """
  def build_order_by(queryable, order_by_params, _build_options, opts) do
    Enum.reduce(order_by_params, queryable, fn {field, format}, queryable ->
      field_atom = SharedHelper.string_to_existing_atom(field)
      apply_order(queryable, field_atom, format, opts[:binding])
    end)
  end

  # Helper function to apply the order clause to the query
  defp apply_order(queryable, field, format, binding) do
    case binding do
      :last ->
        case format do
          "$DESC" ->
            from([q, ..., c] in queryable, order_by: [desc: field(c, ^field)])

          "$ASC" ->
            from([q, ..., c] in queryable, order_by: [asc: field(c, ^field)])

          "$ASC_NULLS_FIRST" ->
            from([q, ..., c] in queryable, order_by: [asc_nulls_first: field(c, ^field)])

          "$ASC_NULLS_LAST" ->
            from([q, ..., c] in queryable, order_by: [asc_nulls_last: field(c, ^field)])

          "$DESC_NULLS_FIRST" ->
            from([q, ..., c] in queryable, order_by: [desc_nulls_first: field(c, ^field)])

          "$DESC_NULLS_LAST" ->
            from([q, ..., c] in queryable, order_by: [desc_nulls_last: field(c, ^field)])

          # Handle unexpected formats gracefully
          _ ->
            queryable
        end

      _ ->
        case format do
          "$DESC" -> from(queryable, order_by: [desc: ^field])
          "$ASC" -> from(queryable, order_by: [asc: ^field])
          "$ASC_NULLS_FIRST" -> from(queryable, order_by: [asc_nulls_first: ^field])
          "$ASC_NULLS_LAST" -> from(queryable, order_by: [asc_nulls_last: ^field])
          "$DESC_NULLS_FIRST" -> from(queryable, order_by: [desc_nulls_first: ^field])
          "$DESC_NULLS_LAST" -> from(queryable, order_by: [desc_nulls_last: ^field])
          # Handle unexpected formats gracefully
          _ -> queryable
        end
    end
  end
end
