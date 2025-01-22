# defmodule FatEcto.FatQuery.FatOrderBy do
#   import Ecto.Query
#   alias FatEcto.FatHelper

#   @moduledoc """
#   Builds query with asc or desc order.

#   ## => $asc

#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `query_opts`  - Include query options as a map.

#   ### Example

#       iex> query_opts = %{
#       ...> "$select" => %{
#       ...>   "$fields" => ["name", "location", "rating"],
#       ...>   "fat_rooms" => ["floor", "name"]
#       ...>  },
#       ...>  "$where" => %{"name" => "saint claire"},
#       ...>  "$group" => ["rating", "total_staff"],
#       ...>  "$order" => %{"total_staff" => "$asc"},
#       ...>  "$include" => %{
#       ...>    "fat_doctors" => %{
#       ...>     "$include" => ["fat_patients"],
#       ...>     "$where" => %{"rating" => %{"$gt" => 5}},
#       ...>     "$order" => %{"experience_years" => "$asc"},
#       ...>     "$select" => ["name", "designation", "phone"]
#       ...>    }
#       ...>   },
#       ...>  "$right_join" => %{
#       ...>    "fat_rooms" => %{
#       ...>      "$on_field" => "id",
#       ...>      "$on_table_field" => "hospital_id",
#       ...>      "$select" => ["floor", "name", "is_active"],
#       ...>      "$where" => %{"floor" => 10},
#       ...>      "$order" => %{"name" => "$asc"}
#       ...>     }
#       ...>   }
#       ...> }
#       iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
#       #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in \"fat_rooms\", on: f0.id == f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.name == ^\"saint claire\" and ^true, where: f1.floor == ^10 and ^true, where: f2.rating > ^5 and ^true, group_by: [f0.rating], group_by: [f0.total_staff], order_by: [asc: f1.name], order_by: [asc: f2.experience_years], order_by: [asc: f0.total_staff], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]), %{^\"fat_rooms\" => map(f1, [:floor, :name, :is_active])}), preload: [[fat_doctors: [:fat_patients]]]>

#   ### Options
#   - `$select`              - Select the fields from `hospital` and `rooms`.
#   - `$right_join: :$select`- Select the fields from  `rooms`.
#   - `$include: :$select`   - Select the fields from  `doctors`.
#   - `$right_join`          - Right join the table `rooms`.
#   - `$include`             - Include the assoication model `doctors` and `patients`.
#   - `$gt`                  - Added the greaterthan attribute in the  where query inside include .
#   - `$order`               - Sort the result based on the order attribute.
#   - `$right_join: :$order` - Sort the result based on the order attribute inside join.
#   - `$include: :$order`    - Sort the result based on the order attribute inside include.
#   - `$group`               - Added the group_by attribute in the query.

#   ## => $desc

#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `query_opts`  - Include query options as a map.

#   ### Example

#        iex> query_opts = %{
#        ...> "$select" => %{
#        ...>   "$fields" => ["name", "location", "rating"],
#        ...>   "fat_rooms" => ["floor", "name"]
#        ...>  },
#        ...>  "$where" => %{"name" => "saint claire"},
#        ...>  "$group" => ["rating", "total_staff"],
#        ...>  "$order" => %{"rating" => "$desc"},
#        ...>  "$include" => %{
#        ...>    "fat_doctors" => %{
#        ...>     "$include" => ["fat_patients"],
#        ...>     "$where" => %{"rating" => %{"$gt" => 5}},
#        ...>     "$order" => %{"experience_years" => "$asc"},
#        ...>     "$select" => ["name", "designation", "phone"]
#        ...>    }
#        ...>   },
#        ...>  "$right_join" => %{
#        ...>    "fat_rooms" => %{
#        ...>      "$on_field" => "id",
#        ...>      "$on_table_field" => "hospital_id",
#        ...>      "$select" => ["name", "floor", "is_active"],
#        ...>      "$where" => %{"floor" => 10},
#        ...>      "$order" => %{"floor" => "$desc"}
#        ...>     }
#        ...>   }
#        ...> }
#        iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
#        #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in \"fat_rooms\", on: f0.id == f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.name == ^\"saint claire\" and ^true, where: f1.floor == ^10 and ^true, where: f2.rating > ^5 and ^true, group_by: [f0.rating], group_by: [f0.total_staff], order_by: [desc: f1.floor], order_by: [asc: f2.experience_years], order_by: [desc: f0.rating], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, fat_rooms: [:floor, :name]]), %{\n  ^\"fat_rooms\" => map(f1, [:name, :floor, :is_active])\n}), preload: [fat_doctors: [:fat_patients]]>

#   ### Options
#   - `$select`              - Select the fields from `hospital` and `rooms`.
#   - `$right_join: :$select`- Select the fields from  `rooms`.
#   - `$include: :$select`   - Select the fields from  `doctors`.
#   - `$right_join`          - Right join the table `rooms`.
#   - `$include`             - Include the assoication model `doctors` and `patients`.
#   - `$gt`                  - Added the greaterthan attribute in the  where query inside include .
#   - `$order`               - Sort the result based on the order attribute.
#   - `$right_join: :$order` - Sort the result based on the order attribute inside join.
#   - `$include: :$order`    - Sort the result based on the order attribute inside include.
#   - `$group`               - Added the group_by attribute in the query.

#   """

#   alias FatEcto.FatHelper

#   def build_order_by(queryable, group_params, build_options, opts \\ [])

#   def build_order_by(queryable, nil, _build_options, _opts) do
#     queryable
#   end

#   @doc """
#   Order the results with respect to order_by clause in the params.

#   ### Parameters

#     - `queryable`        - Ecto Queryable that represents your schema name, table name or query.
#     - `order_by_params`  - Order_By query options as a map.
#     - `opts`             - Pass options related to query bindings.
#     - `build_options`    - Pass options related to otp_app.

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$select" => %{
#       ...>    "$fields" => ["name", "location", "rating"],
#       ...>    "fat_rooms" => ["name", "floor"]
#       ...>  },
#       ...>  "$order" => %{"id" => "$asc"},
#       ...>  "$where" => %{"rating" => 4},
#       ...>  "$include" => %{
#       ...>    "fat_doctors" => %{
#       ...>      "$include" => ["fat_patients"],
#       ...>      "$where" => %{"designation" => "ham"},
#       ...>      "$order" => %{"id" => "$desc"}
#       ...>    }
#       ...>  }
#       ...> }
#       iex> #{__MODULE__}.build_order_by(FatEcto.FatHospital, query_opts["$order"], [], [])
#       #Ecto.Query<from f0 in FatEcto.FatHospital, order_by: [asc: f0.id]>
#   """

#   def build_order_by(queryable, order_by_params, build_options, opts) do
#     Enum.reduce(order_by_params, queryable, fn {field, format}, queryable ->
#       FatHelper.check_params_validity(build_options, queryable, field)

#       if opts[:binding] == :last do
#         case format do
#           "$desc" ->
#             from([q, ..., c] in queryable,
#               order_by: [desc: field(c, ^FatHelper.string_to_existing_atom(field))]
#             )

#           "$asc" ->
#             from(
#               [q, ..., c] in queryable,
#               order_by: [
#                 asc: field(c, ^FatHelper.string_to_existing_atom(field))
#               ]
#             )

#           "$asc_nulls_first" ->
#             from(
#               [q, ..., c] in queryable,
#               order_by: [
#                 asc_nulls_first: field(c, ^FatHelper.string_to_existing_atom(field))
#               ]
#             )

#           "$asc_nulls_last" ->
#             from(
#               [q, ..., c] in queryable,
#               order_by: [
#                 asc_nulls_last: field(c, ^FatHelper.string_to_existing_atom(field))
#               ]
#             )

#           "$desc_nulls_first" ->
#             from(
#               [q, ..., c] in queryable,
#               order_by: [
#                 desc_nulls_first: field(c, ^FatHelper.string_to_existing_atom(field))
#               ]
#             )

#           "$desc_nulls_last" ->
#             from(
#               [q, ..., c] in queryable,
#               order_by: [
#                 desc_nulls_last: field(c, ^FatHelper.string_to_existing_atom(field))
#               ]
#             )
#         end
#       else
#         case format do
#           "$desc" ->
#             from(queryable,
#               order_by: [desc: ^FatHelper.string_to_existing_atom(field)]
#             )

#           "$asc" ->
#             from(
#               queryable,
#               order_by: [
#                 asc: ^FatHelper.string_to_existing_atom(field)
#               ]
#             )

#           "$asc_nulls_first" ->
#             from(
#               queryable,
#               order_by: [
#                 asc_nulls_first: ^FatHelper.string_to_existing_atom(field)
#               ]
#             )

#           "$asc_nulls_last" ->
#             from(
#               queryable,
#               order_by: [
#                 asc_nulls_last: ^FatHelper.string_to_existing_atom(field)
#               ]
#             )

#           "$desc_nulls_first" ->
#             from(
#               queryable,
#               order_by: [
#                 desc_nulls_first: ^FatHelper.string_to_existing_atom(field)
#               ]
#             )

#           "$desc_nulls_last" ->
#             from(
#               queryable,
#               order_by: [
#                 desc_nulls_last: ^FatHelper.string_to_existing_atom(field)
#               ]
#             )
#         end
#       end
#     end)
#   end
# end
