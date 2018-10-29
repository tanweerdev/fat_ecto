defmodule FatEcto.FatQuery.FatOrderBy do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      alias FatEcto.FatHelper
      # TODO: Add docs and examples for ex_doc
      @doc """
      Build a  `order_by query` depending on the params.
      ## Parameters

        - `queryable`- Schema name that represents your database model.
        - `query_opts` - include query options as a map
      ## Examples
          query_opts = %{
            "$select" => %{
              "$fields" => ["name", "location", "rating"],
              "fat_rooms" => ["beds", "capacity"]
            },
            "$order" => %{"id" => "$asc"},
            "$where" => %{"rating" => 4},
            "$include" => %{
              "fat_doctors" => %{
                "$include" => ["fat_patients"],
                "$where" => %{"name" => "ham"},
                "$order" => %{"id" => "$desc"}
              }
            }
          }

          iex> build(FatEcto.FatHospital, query_opts)
               #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors),
               where: f0.rating == ^4 and ^true, order_by: [asc: f0.id],
               select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]),
               preload: [fat_doctors: #Ecto.Query<from f0 in FatEcto.FatDoctor, left_join: f1 in assoc(f0, :fat_patients), where: f0.name == ^"ham" and ^true, order_by: [desc: f0.id], limit: ^10, offset: ^0, preload: [:fat_patients]>]>

      ## Options

        - `$include`- Include the assoication `doctors`.
        - `$select`- Select the fields `from FatEcto.FatHospital` and `rooms`.
        - `$where`- Added the where attribute in the query.
        - `$order`- Sort the result based on the order attribute.
      """
      def build_order_by(queryable, opts_order_by) do
        if opts_order_by == nil do
          queryable
        else
          # TODO: Add docs and examples of ex_doc for this case here
          Enum.reduce(opts_order_by, queryable, fn {field, format}, queryable ->
            # TODO: Add docs and examples of ex_doc for this case here
            if format == "$desc" do
              from(
                queryable,
                order_by: [
                  desc: ^FatHelper.string_to_existing_atom(field)
                ]
              )
            else
              # TODO: Add docs and examples of ex_doc for this case here
              from(
                queryable,
                order_by: [
                  asc: ^FatHelper.string_to_existing_atom(field)
                ]
              )
            end
          end)
        end
      end
    end
  end
end
