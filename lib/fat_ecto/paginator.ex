defmodule FatEcto.FatPaginator do
  # TODO: make paginator optional via global config and via options passed
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(options) do
    quote location: :keep do
      import Ecto.Query

      # TODO: @repo.all and @repo.one nil warning
      @options unquote(options)
      # TODO: Add docs and examples for ex_doc
      @doc """
         Apply limit and offset to the query if not provided and return meta.

      ## Parameters

        - `queryable`- Schema name that represents your database model.
        - `query_opts` - include query options as a map

      ## Examples
          iex> query_opts = %{
          ...>  "$find" => "$all",
          ...>  "$select" => %{"$fields" => ["name", "rating"], "fat_rooms" => ["beds"]},
          ...>  "$where" => %{"id" => 10},
          ...>  "$limit" => 15,
          ...>  "$skip" => 0
          ...> }
          iex> build(FatEcto.FatHospital, query_opts)
          #Result




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
        {limit, _params} = FatEcto.FatHelper.get_limit_value(params, @options)

        %{
          data_query: data_query(query, skip, limit),
          skip: skip,
          limit: limit,
          count_query: count_query(query)
        }
      end

      defp data_query(query, skip, limit) do
        query
        |> limit([q], ^limit)
        |> offset([q], ^skip)
      end

      defp count_query(query) do
        queryable =
          query
          |> exclude(:order_by)
          |> exclude(:preload)
          |> aggregate()

        # |> exclude(:select)
        # |> exclude(:distinct)

        # from(q in queryable, select: fragment("count(*)"))
      end

      defp aggregate(%{distinct: %{expr: [_ | _]}} = query) do
        query
        |> exclude(:select)
        |> count()
      end

      defp aggregate(
             %{
               group_bys: [
                 %Ecto.Query.QueryExpr{
                   expr: [{{:., [], [{:&, [], [source_index]}, field]}, [], []} | _]
                 }
                 | _
               ]
             } = query
           ) do
        query
        |> exclude(:select)
        |> select([{x, source_index}], struct(x, ^[field]))
        |> count()
      end

      defp aggregate(query) do
        primary_keys = FatEcto.FatHelper.get_primary_keys(query, @options[:otp_app])

        if Enum.count(primary_keys) == 1 do
          query
          |> exclude(:select)
        else
          query
          |> exclude(:select)
          |> select(count("*"))
        end
      end

      defp count(query) do
        query
        |> subquery
        |> select(count("*"))
      end
    end
  end
end
