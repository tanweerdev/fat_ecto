# defmodule FatEcto.FatQuery.FatInclude do
#   alias FatEcto.FatHelper
#   import Ecto.Query

#   @moduledoc """
#   Preload associated schemas based on the conditions passed in the query params.
#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `query_opts`  - Include query options as a map

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$select" => %{
#       ...>    "$fields" => ["location", "rating"],
#       ...>    "fat_rooms" => ["name", "floor"]
#       ...>  },
#       ...>  "$order" => %{"id" => "$desc"},
#       ...>  "$where" => %{"rating" => 4},
#       ...>  "$include" => %{
#       ...>    "fat_doctors" => %{
#       ...>      "$include" => %{"fat_patients" => %{}},
#       ...>      "$order" => %{"id" => "$desc"},
#       ...>      "$where" => %{"experience_years" => 3},
#       ...>      "$join" => "$right"
#       ...>    }
#       ...>  }
#       ...> }
#       iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
#       #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in assoc(f0, :fat_doctors), left_join: f2 in assoc(f1, :fat_patients), where: f0.rating == ^4 and ^true, where: f1.experience_years == ^3 and ^true, order_by: [desc: f1.id], order_by: [desc: f0.id], limit: ^34, offset: ^0, select: map(f0, [:location, :rating, {:fat_rooms, [:name, :floor]}]), preload: [[fat_doctors: [:fat_patients]]]>

#   ## Options

#     - `$include`               - Include the assoication `doctors`.
#     - `$include: :fat_patients`- Include the assoication `patients` which has association with `doctors`.
#     - `$select`                - Select the fields from `hospital` and `rooms`.
#     - `$where`                 - Added the where attribute in the query.
#     - `$order`                 - Sort the result based on the order attribute.
#     - `$join`                  - Join the `doctors` table with `hospital` .

#   """

#   @spec build_include(any, nil | binary | maybe_improper_list | map, any, any) :: any
#   def build_include(queryable, nil, _model, _build_options) do
#     queryable
#   end

#   @doc """
#   Preload associated schemas.
#   ### Parameters

#     - `queryable`      -  Ecto Queryable that represents your schema name, table name or query.
#     - `include_params` -  Include query options as a map.
#     - `model`          - `schema` name of the table.
#     - `build_options`  -  Pass options related to otp_app.

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$include" => %{
#       ...>    "fat_doctors" => %{
#       ...>      "$include" => %{"fat_patients" => %{}},
#       ...>      "$order" => %{"id" => "$desc"},
#       ...>      "$where" => %{"experience_years" => 3},
#       ...>      "$join" => "$right"
#       ...>    }
#       ...>  }
#       ...> }
#       iex> #{__MODULE__}.build_include(FatEcto.FatHospital, query_opts["$include"], FatEcto.FatHospital, [])
#       #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in assoc(f0, :fat_doctors), left_join: f2 in assoc(f1, :fat_patients), where: f1.experience_years == ^3 and ^true, order_by: [desc: f1.id], limit: ^10, offset: ^0>

#       iex> query_opts = %{
#       ...>  "$include" => %{
#       ...>    "fat_doctors" => %{
#       ...>     "$include" => ["fat_patients"],
#       ...>      "$order" => %{"id" => "$desc"},
#       ...>      "$join" => "$left"
#       ...>    }
#       ...>  }
#       ...> }
#       iex> #{__MODULE__}.build_include(FatEcto.FatHospital, query_opts["$include"], FatEcto.FatHospital, [])
#       #Ecto.Query<from f0 in FatEcto.FatHospital, left_join: f1 in assoc(f0, :fat_doctors), order_by: [desc: f1.id], limit: ^10, offset: ^0>

#   """

#   def build_include(queryable, include_params, model, build_options) do
#     case include_params do
#       include when is_map(include) ->
#         FatHelper.dynamic_binding(include)
#         |> Enum.reduce(queryable, fn {key, value}, queryable ->
#           relation_name = FatHelper.string_to_existing_atom(key)

#           %{owner: _o, owner_key: _ok, related: related_model, related_key: _rk} =
#             FatHelper.model_related_owner(model, relation_name)

#           {limit, _} = FatHelper.get_limit_value([limit: value["$limit"]], build_options)

#           join =
#             String.replace(value["$join"] || "", "$", "")
#             |> FatHelper.string_to_atom()

#           query =
#             case value["$binding"] do
#               :last ->
#                 if join != :"" do
#                   queryable
#                   |> join(join, [q, ..., c], jn in assoc(c, ^relation_name))
#                 else
#                   queryable
#                   |> join(:left, [q, ..., c], jn in assoc(c, ^relation_name))
#                 end

#               _ ->
#                 if join != :"" do
#                   queryable
#                   |> join(join, [q, ..., c], jn in assoc(q, ^relation_name))
#                 else
#                   queryable
#                   |> join(:left, [q, ..., c], jn in assoc(q, ^relation_name))
#                 end
#             end

#           query
#           |> FatEcto.FatQuery.FatWhere.build_where(value["$where"], build_options ++ [table: key],
#             binding: :last
#           )
#           |> FatEcto.FatQuery.FatOrderBy.build_order_by(value["$order"], build_options ++ [table: key],
#             binding: :last
#           )
#           |> FatEcto.FatQuery.FatGroupBy.build_group_by(value["$group"], build_options ++ [table: key],
#             binding: :last
#           )
#           |> build_include(value["$include"], related_model, build_options ++ [relation: relation_name])
#           |> limit([q], ^limit)
#           |> offset([q], ^(value["$offset"] || 0))
#         end)

#       include when is_binary(include) ->
#         relation = build_options[:relation]

#         if !is_nil(relation) do
#           queryable
#         else
#           from(
#             queryable,
#             # left_join: a in assoc(q, ^FatHelper.string_to_existing_atom(include)),
#             preload: [^FatHelper.string_to_existing_atom(include)]
#           )
#         end

#       include when is_list(include) ->
#         relation = build_options[:relation]

#         # TODO: implement logic for the
#         Enum.reduce(include, queryable, fn model, queryable ->
#           # case model do
#           # TODO: include: [{hospital: {$fields: [], $where: {}}}, {rooms: {$fields: [], $where: {}}}]
#           #   m when is_map(m) ->
#           #     queryable

#           #   m when is_binary(m) ->
#           if !is_nil(relation) do
#             queryable
#             # left_join: a in assoc(q, ^FatHelper.string_to_existing_atom(model)),
#           else
#             from(
#               queryable,
#               # left_join: a in assoc(q, ^FatHelper.string_to_existing_atom(model)),
#               preload: [^FatHelper.string_to_existing_atom(model)]
#             )

#             # end
#           end
#         end)
#     end
#   end

#   @doc false

#   def build_include_preloads(queryable, nil) do
#     queryable
#   end

#   @doc false

#   def build_include_preloads(queryable, include_params) do
#     case include_params do
#       include when is_map(include) ->
#         preloads =
#           FatHelper.dynamic_binding(include)
#           |> FatHelper.dynamic_preloading()

#         from(q in queryable,
#           preload: ^preloads
#         )

#       _ ->
#         queryable
#     end
#   end
# end
