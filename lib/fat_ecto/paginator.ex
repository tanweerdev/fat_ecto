defmodule FatEcto.FatPaginator do
  @moduledoc false

  # TODO: make paginator optional via global config and via options passed

  defmacro __using__(options \\ []) do
    quote location: :keep do
      import Ecto.Query

      # TODO: @repo.all and @repo.one nil warning
      @options FatEcto.FatHelper.get_module_options(unquote(options), FatEcto.FatPaginator)
      @doc """
        Paginate the records.
      ### Parameters

         - `query`   - Ecto Queryable that represents your schema name, table name or query.
         - `params`  - limit and skip values.

      ### Examples

              iex> query_opts = %{
              ...>    "$select" => %{
              ...>     "$fields" => ["name", "location", "rating"]
              ...>    },
              ...>   "$where" => %{
              ...>      "name" => "%John%",
              ...>      "location" => nil,
              ...>      "rating" => "$not_null",
              ...>      "total_staff" => %{"$between" => [1, 3]}
              ...>    }
              ...>  }
              iex> query = #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
              iex> result = #{__MODULE__}.paginate(query, [limit: 10, skip: 0])
              iex>  %{count_query: count_query, data_query: data_query, limit: limit, skip: skip} = result
              iex> limit
              10
              iex> skip
              0
              iex> count_query
              #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff > ^1 and f0.total_staff < ^3 and
                (not is_nil(f0.rating) and (f0.name == ^"%John%" and (is_nil(f0.location) and ^true))), distinct: true>
              iex> data_query
              #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff > ^1 and f0.total_staff < ^3 and
                (not is_nil(f0.rating) and (f0.name == ^\"%John%\" and (is_nil(f0.location) and ^true))), limit: ^10, offset: ^0>
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
          |> exclude(:distinct)

        distinct(queryable, true)

        # |> exclude(:select)

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
        primary_keys = FatEcto.FatHelper.get_primary_keys(query)
        # TODO: Make this part dynamic
        if !is_nil(primary_keys) do
          case Enum.count(primary_keys) do
            1 ->
              exclude(query, :select)

            2 ->
              query
              |> exclude(:select)
              |> select(
                [q, _, _, c],
                fragment(
                  "COUNT(DISTINCT ROW(?, ?))::int",
                  field(q, ^Enum.at(primary_keys, 0)),
                  field(q, ^Enum.at(primary_keys, 1))
                )
              )

            3 ->
              query
              |> exclude(:select)
              |> select(
                [q, _, _, c],
                fragment(
                  "COUNT(DISTINCT ROW(?, ?, ?))::int",
                  field(q, ^Enum.at(primary_keys, 0)),
                  field(q, ^Enum.at(primary_keys, 1)),
                  field(q, ^Enum.at(primary_keys, 2))
                )
              )

            4 ->
              query
              |> exclude(:select)
              |> select(
                [q, _, _, c],
                fragment(
                  "COUNT(DISTINCT ROW(?, ?, ?, ?))::int",
                  field(q, ^Enum.at(primary_keys, 0)),
                  field(q, ^Enum.at(primary_keys, 1)),
                  field(q, ^Enum.at(primary_keys, 2)),
                  field(q, ^Enum.at(primary_keys, 3))
                )
              )

            5 ->
              query
              |> exclude(:select)
              |> select(
                [q, _, _, c],
                fragment(
                  "COUNT(DISTINCT ROW(?, ?, ?, ?, ?))::int",
                  field(q, ^Enum.at(primary_keys, 0)),
                  field(q, ^Enum.at(primary_keys, 1)),
                  field(q, ^Enum.at(primary_keys, 2)),
                  field(q, ^Enum.at(primary_keys, 3)),
                  field(q, ^Enum.at(primary_keys, 4))
                )
              )

            _ ->
              query
              |> exclude(:select)
              |> select(count("*"))
          end
        else
          query
          |> exclude(:select)
          |> select(count("*"))
        end
      end

      defp count(query) do
        query
        |> exclude(:limit)
        |> exclude(:offset)
        |> subquery
        |> select(count("*"))
      end
    end
  end
end
