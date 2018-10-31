defmodule FatEcto.FatPaginator do
  # TODO: make paginator optional via global config and via options passed
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(options) do
    quote location: :keep do
      import Ecto.Query
      # TODO: @repo.all and @repo.one nil warning
      @repo unquote(options)[:repo]
      # TODO: Add docs and examples for ex_doc
      @doc """
        Apply limit and offset to the query if not provided and return meta.

      ## Parameters

        - `queryable`- Schema name that represents your database model.
        - `query_opts` - include query options as a map

      ## Examples
          query_opts = %{
          "$find" => "$all",
          "$select" => %{"$fields" => ["name", "rating"], "fat_rooms" => ["beds"]},
          "$where" => %{"id" => 10},
          "$limit" => 15,
          "$skip" => 0
          }

          iex> fetch(FatEcto.FatHospital, query_opts)


      ## Options

        - `$find => $all`- To fetch all the results from database.
        - `$find => $one`- To fetch single record from database.
        - `$select`- Select the fields from `hospital` and `rooms`.
        - `$where`- Added the where attribute in the query.
        - `$limit`- Limit the number of records returned from the repo.
        - `$skip`- Used an an offset.

      If no limit is defined in the query. FAT uses the default limit specified in the fat_ecto config. 

      """
      def paginate(query, params) do
        {skip, params} = FatEcto.FatHelper.get_skip_value(params)
        {limit, _params} = FatEcto.FatHelper.get_limit_value(params)

        %{
          data: data(query, skip, limit),
          meta: meta(query, skip, limit)
        }
      end

      defp meta(query, skip, limit) do
        %{
          skip: skip,
          limit: limit,
          count: count(query)
        }
      end

      defp data(query, skip, limit) do
        query
        |> limit([q], ^limit)
        |> offset([q], ^skip)
        |> @repo.all()
      end

      defp count(query) do
        queryable =
          query
          |> exclude(:order_by)
          |> exclude(:preload)
          |> exclude(:select)

        queryable =
          case FatEcto.FatHelper.field_exists?(queryable, :deleted_at) do
            false ->
              queryable

            true ->
              from(p in queryable, where: is_nil(p.deleted_at))
          end

        @repo.one(from(q in queryable, select: fragment("count(*)")))
      end
    end
  end
end
