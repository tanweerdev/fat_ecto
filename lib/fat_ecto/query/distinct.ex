# defmodule FatEcto.FatQuery.FatDistinct do
#   @moduledoc """
#    Builds a query by adding distinct query expression to avoid records duplication.

#   ## => $distinct

#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `query_opts`  - Distinct query options as a map

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$aggregate" => %{"$sum" => "total_staff", "$avg" => "rating"},
#       ...>  "$where" => %{"rating" => 5},
#       ...>  "$group" => "id",
#       ...>  "$distinct" => true
#       ...> }
#       iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
#       #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating == ^5 and ^true, group_by: [f0.id], distinct: true, select: merge(merge(f0, %{\"$aggregate\" => %{\"$avg\": %{^\"rating\" => avg(f0.rating)}}}), %{\"$aggregate\" => %{\"$sum\": %{^\"total_staff\" => sum(f0.total_staff)}}})>

#   ## Options

#     - `$aggregate`- Specify the type of aggregate method/methods to apply.
#     - `$where`    - Added the where attribute in the query.
#     - `$group`    - Group the records with a specific field.
#     - `$distinct` - Select only distinct records.

#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `query_opts`  - Distinct query options as a map

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$aggregate" => %{"$sum" => "total_staff", "$avg" => "rating"},
#       ...>  "$where" => %{"rating" => 5},
#       ...>  "$group" => "id",
#       ...>  "$distinct" => "id"
#       ...> }
#       iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
#       #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating == ^5 and ^true, group_by: [f0.id], distinct: [asc: f0.id], select: merge(merge(f0, %{\"$aggregate\" => %{\"$avg\": %{^\"rating\" => avg(f0.rating)}}}), %{\"$aggregate\" => %{\"$sum\": %{^\"total_staff\" => sum(f0.total_staff)}}})>

#   ## Options

#     - `$aggregate`- Specify the type of aggregate method/methods to apply.
#     - `$where`- Added the where attribute in the query.
#     - `$group`- Group the records with a specific field.
#     - `$distinct`- Select only distinct records.

#   ## => $distinct_nested

#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `query_opts`  - Distinct query options as a map.

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$aggregate" => %{"$sum" => "total_staff", "$avg" => "rating"},
#       ...>  "$where" => %{"rating" => 5},
#       ...>  "$include" => %{
#       ...>    "fat_doctors" => %{
#       ...>      "$order" => %{"id" => "$asc"}
#       ...>    }
#       ...>  },
#       ...>  "$group" => "id",
#       ...>  "$distinct" => true,
#       ...>  "$distinct_nested" => true
#       ...> }
#       iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
#       #Ecto.Query<from f0 in FatEcto.FatHospital, left_join: f1 in assoc(f0, :fat_doctors), where: f0.rating == ^5 and ^true, group_by: [f0.id], limit: ^34, offset: ^0, distinct: true, select: merge(merge(f0, %{\"$aggregate\" => %{\"$avg\": %{^\"rating\" => avg(f0.rating)}}}), %{\n  \"$aggregate\" => %{\"$sum\": %{^\"total_staff\" => sum(f0.total_staff)}}\n}), preload: [:fat_doctors]>

#   ## Options

#     - `$aggregate`- Specify the type of aggregate method/methods to apply.
#     - `$where`- Added the where attribute in the query.
#     - `$group`- Group the records with a specific field.
#     - `$distinct`- Select only distinct records.
#     - `$distinct_nested`- Remove nested order_by clauses.
#   """
#   import Ecto.Query
#   alias FatEcto.FatHelper
#   alias FatEcto.FatHelper

#   def build_distinct(queryable, nil, _options) do
#     queryable
#   end

#   @doc """
#     Builds a query with distinct expression.
#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `field`       - Distinct query options as a map.
#     - `options`     - Pass options related to otp_app and it's config.

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$aggregate" => %{"$sum" => "total_staff", "$avg" => "rating"},
#       ...>  "$where" => %{"rating" => 5},
#       ...>  "$group" => "id",
#       ...>  "$distinct" => true
#       ...> }
#       iex> #{__MODULE__}.build_distinct(FatEcto.FatHospital, query_opts["$distinct"], [])
#       #Ecto.Query<from f0 in FatEcto.FatHospital, distinct: true>

#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `field`       - Distinct query options as a map.
#     - `options`     - Pass options related to otp_app.

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$aggregate" => %{"$sum" => "total_staff", "$avg" => "rating"},
#       ...>  "$where" => %{"rating" => 5},
#       ...>  "$group" => "id",
#       ...>  "$distinct" => "id"
#       ...> }
#       iex> #{__MODULE__}.build_distinct(FatEcto.FatHospital, query_opts["$distinct"], [])
#       #Ecto.Query<from f0 in FatEcto.FatHospital, distinct: [asc: f0.id]>
#   """
#   def build_distinct(queryable, field, options) when is_boolean(field) do
#     FatHelper.params_valid(queryable, field, options)

#     from(q in queryable,
#       distinct: ^field
#     )
#   end

#   def build_distinct(queryable, field, options) do
#     FatHelper.params_valid(queryable, field, options)

#     from(q in queryable,
#       distinct: ^FatHelper.string_to_atom(field)
#     )
#   end
# end
