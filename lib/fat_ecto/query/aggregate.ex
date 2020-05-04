defmodule FatEcto.FatQuery.FatAggregate do
  @moduledoc """
  Builds an aggregate query with an aggregate method passed in the params as a string or list.
  ## => $sum/$avg

  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Aggregate query options as a map.

  ### Examples

      iex> query_opts = %{
      ...>  "$aggregate" => %{"$sum" => "total_staff", "$avg" => "rating"},
      ...>  "$where" => %{"rating" => 5},
      ...>  "$group" => "id" 
      ...> }   
      iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating == ^5 and ^true, group_by: [f0.id], select: merge(merge(merge(f0, %{"$aggregate" => %{"$avg": %{^"rating" => avg(f0.rating)}}}), %{"$aggregate" => %{"$sum": %{^"total_staff" => sum(f0.total_staff)}}}), %{"$group" => %{^"id" => f0.id}})>

  ## Options

    - `$aggregate`- Specify the type of aggregate method/methods to apply.
    - `$where`    - Added the where attribute in the query.
    - `$group`    - Group the records with a specific field.

  ## => $min/$max

  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Aggregate query options as a map.

  ### Examples

      iex> query_opts = %{
      ...>  "$aggregate" => %{"$min" => "total_staff", "$max" => "rating"},
      ...>  "$where" => %{"rating" => 5},
      ...>  "$group" => "id" 
      ...> }   
      iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating == ^5 and ^true, group_by: [f0.id], select: merge(merge(merge(f0, %{"$aggregate" => %{"$max": %{^"rating" => max(f0.rating)}}}), %{"$aggregate" => %{"$min": %{^"total_staff" => min(f0.total_staff)}}}), %{"$group" => %{^"id" => f0.id}})>

  ## Options

    - `$aggregate`- Specify the type of aggregate method/methods to apply.
    - `$where`    - Added the where attribute in the query.
    - `$group`    - Group the records with a specific field. 
    
  ## => $count/$count_distinct

  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Aggregate query options as a map.

  ### Examples

      iex> query_opts = %{
      ...>  "$aggregate" => %{"$count" => ["total_staff"], "$count_distinct" => ["rating"]},
      ...>  "$where" => %{"rating" => 5},
      ...>  "$group" => "id" 
      ...> }   
      iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating == ^5 and ^true, group_by: [f0.id], select: merge(merge(merge(f0, %{"$aggregate" => %{"$count": %{^"total_staff" => count(f0.total_staff)}}}), %{"$aggregate" => %{"$count_distinct": %{^"rating" => count(f0.rating, :distinct)}}}), %{"$group" => %{^"id" => f0.id}})>

  ## Options

    - `$aggregate` - Specify the type of aggregate method/methods to apply.
    - `$where`     - Added the where attribute in the query.
    - `$group`     - Group the records with a specific field.   
  """
  import Ecto.Query
  alias FatEcto.FatHelper

  def build_aggregate(queryable, nil, _options) do
    queryable
  end

  @doc """
   Builds an aggregate query.
  ### Parameters

    - `queryable`         - Ecto Queryable that represents your schema name, table name or query.
    - `aggregate_params`  - Aggregate query options as a map.
    - `options`           - Pass options related to otp_app.

  ### Examples

      iex> query_opts = %{
      ...>  "$aggregate" => %{"$count" => ["total_staff"], "$count_distinct" => ["rating"]},
      ...>  "$where" => %{"rating" => 5},
      ...>  "$group" => "id" 
      ...> }   
      iex> #{__MODULE__}.build_aggregate(FatEcto.FatHospital, query_opts["$aggregate"], [])
      #Ecto.Query<from f0 in FatEcto.FatHospital, select: merge(merge(f0, %{"$aggregate" => %{"$count": %{^"total_staff" => count(f0.total_staff)}}}), %{"$aggregate" => %{"$count_distinct": %{^"rating" => count(f0.rating, :distinct)}}})>
  """
  def build_aggregate(queryable, aggregate_params, options) do
    Enum.reduce(aggregate_params, queryable, fn {aggregate_type, fields}, queryable ->
      FatHelper.params_valid(queryable, fields, options)

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
        "$aggregate" => %{"$max": %{^field => max(field(q, ^atom_field))}}
      }
    )
  end

  defp build_min(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{"$aggregate" => %{"$min": %{^field => min(field(q, ^atom_field))}}}
    )
  end

  defp build_avg(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{"$aggregate" => %{"$avg": %{^field => avg(field(q, ^atom_field))}}}
    )
  end

  defp build_count(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{"$aggregate" => %{"$count": %{^field => count(field(q, ^atom_field))}}}
    )
  end

  defp build_count_distinct(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{
        "$aggregate" => %{"$count_distinct": %{^field => count(field(q, ^atom_field), :distinct)}}
      }
    )
  end

  defp build_sum(queryable, field) do
    atom_field = FatHelper.string_to_atom(field)

    from(
      q in queryable,
      select_merge: %{"$aggregate" => %{"$sum": %{^field => sum(field(q, ^atom_field))}}}
    )
  end
end
