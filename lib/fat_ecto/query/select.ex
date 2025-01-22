# defmodule FatEcto.FatQuery.FatSelect do
#   alias FatEcto.FatHelper
#   import Ecto.Query

#   @moduledoc """
#   Builds a `select` query based on the params passed.

#   ### Parameters

#     - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
#     - `query_opts`  - Include query options as a map

#   ### Examples

#       iex> query_opts = %{
#       ...>  "$select" => %{
#       ...>    "$fields" => ["name", "location", "rating"],
#       ...>    "fat_rooms" => ["beds", "capacity"]
#       ...>  },
#       ...>  "$order" => %{"id" => "$desc"},
#       ...>  "$where" => %{"rating" => 4},
#       ...> "$include" => %{
#       ...>    "fat_doctors" => %{
#       ...>      "$include" => ["fat_patients"],
#       ...>      "$where" => %{"name" => "ham"},
#       ...>      "$order" => %{"id" => "$desc"}
#       ...>    }
#       ...>  }
#       ...> }
#       iex> #{FatEcto.FatQuery}.build(FatEcto.FatHospital, query_opts)
#       #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, order_by: [desc: f0.id], select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.name == ^"ham" and ^true, order_by: [desc: f.id], limit: ^10, offset: ^0, preload: [:fat_patients]>]>

#   ## Options

#     - `$include`               - Include the assoication `doctors`.
#     - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
#     - `$select`                - Select the fields from `hospital` and `rooms`.
#     - `$where`                 - Added the where attribute in the query.
#     - `$order`                 - Sort the result based on the order attribute.

#   """

#   def build_select(queryable, nil, _model, _options) do
#     queryable
#   end

#   def build_select(queryable, select_params, _model, options) do
#     case select_params do
#       # TODO: Add docs and examples of ex_doc for this case here
#       select when is_map(select) ->
#         # TODO: Add docs and examples of ex_doc for this case here
#         fields = select_map_field(queryable, select, options)

#         from(q in queryable, select: map(q, ^Enum.uniq(fields)))

#       select when is_list(select) ->
#         FatHelper.params_valid(queryable, select, options)

#         from(
#           q in queryable,
#           select:
#             map(
#               q,
#               ^Enum.uniq(Enum.map(select, &FatHelper.string_to_existing_atom/1))
#             )
#         )
#     end
#   end

#   defp select_map_field(queryable, fields, options, fields \\ [])

#   defp select_map_field(queryable, fields_map, options, fields) when is_map(fields_map) do
#     Enum.reduce(fields_map, fields, fn {key, value}, fields ->
#       cond do
#         key == "$fields" and is_list(value) ->
#           FatHelper.params_valid(queryable, value, options)
#           fields ++ Enum.map(value, &FatHelper.string_to_existing_atom/1)

#         key != "$fields" and is_map(value) ->
#           fields ++ [{FatHelper.string_to_existing_atom(key), select_map_field(queryable, value, options)}]

#         key != "$fields" and is_list(value) ->
#           FatHelper.params_valid(key, value, options)

#           fields ++
#             [
#               {FatHelper.string_to_existing_atom(key), Enum.map(value, &FatHelper.string_to_existing_atom/1)}
#             ]
#       end
#     end)
#   end
# end
