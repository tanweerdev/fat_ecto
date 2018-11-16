defmodule FatEcto.FatQuery.FatGroupBy do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      alias FatEcto.FatHelper
      # TODO: Add docs and examples for ex_doc

      @doc """
      Build a  `group_by query` depending on the params.
      ## Parameters

        - `queryable`- Schema name that represents your database model.
        - `query_opts` - include query options as a map
      ## Examples
          iex> query_opts = %{
          ...>  "$select" => %{
          ...>    "$fields" => ["name", "location", "rating"],
          ...>    "fat_rooms" => ["beds", "capacity"]
          ...>  },
          ...>  "$order" => %{"id" => "$desc"},
          ...>  "$where" => %{"rating" => 4},
          ...>  "$group" => "total_staff"
          ...> }
          iex> #{FatEcto.FatQuery}.build(FatEcto.FatHospital, query_opts)
          #Ecto.Query<from f in FatEcto.FatHospital, where: f.rating == ^4 and ^true, group_by: [f.total_staff], order_by: [desc: f.id], select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>



      ## Options

        - `$select`- Select the fields from `hospital` and `rooms`.
        - `$where`- Added the where attribute in the query.
        - `$group`- Added the group_by attribute in the query.
        - `$order`- Sort the result based on the order attribute.
      """

      def build_group_by(queryable, group_by_params) do
        if group_by_params == nil do
          queryable
        else
          case group_by_params do
            group_by_params when is_list(group_by_params) ->
              Enum.reduce(group_by_params, queryable, fn group_by_field, queryable ->
                from(
                  q in queryable,
                  group_by: field(q, ^FatHelper.string_to_existing_atom(group_by_field))
                )
              end)

            group_by_params when is_binary(group_by_params) ->
              from(
                q in queryable,
                group_by: field(q, ^FatHelper.string_to_existing_atom(group_by_params))
              )
          end
        end
      end
    end
  end
end
