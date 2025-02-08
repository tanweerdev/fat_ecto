defmodule FatEcto.FatPaginator do
  @moduledoc """
  Provides pagination functionality for Ecto queries.

  This module can be used to paginate query results by specifying `limit` and `skip` parameters.
  It also supports counting the total number of records for pagination metadata.

  ## Usage

      defmodule Fat.MyContext do
        use FatEcto.FatPaginator, repo: Fat.Repo

        # Custom functions can be added here
      end

  Now you can use the `paginate/2` function within `Fat.MyContext`.
  """

  defmacro __using__(options \\ []) do
    quote location: :keep do
      import Ecto.Query

      @options unquote(options)

      @doc """
      Paginates the given query with the provided parameters.

      ## Parameters
      - `query`: The Ecto query to paginate.
      - `params`: A keyword list or map containing `limit` and `skip` values.

      ## Returns
      A map containing:
      - `data_query`: The paginated query.
      - `count_query`: The query to count the total number of records.
      - `limit`: The limit value used for pagination.
      - `skip`: The skip value used for pagination.

      ## Examples

          iex> import Ecto.Query
          iex> query = from(h in FatEcto.FatHospital)
          iex> result = FatEcto.Sample.Pagination.paginate(query, limit: 10, skip: 0)
          iex> %{data_query: data_query, count_query: count_query, limit: limit, skip: skip} = result
          iex> limit
          10
          iex> skip
          0
          iex> data_query
          #Ecto.Query<from f0 in FatEcto.FatHospital, limit: ^10, offset: ^0>
          iex> count_query
          #Ecto.Query<from f0 in FatEcto.FatHospital, distinct: true>
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
        |> limit(^limit)
        |> offset(^skip)
      end

      defp count_query(query) do
        query
        |> exclude(:order_by)
        |> exclude(:preload)
        |> aggregate()
        |> exclude(:distinct)
        |> distinct(true)
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

        case primary_keys do
          nil ->
            query
            |> exclude(:select)
            |> select(count("*"))

          keys when is_list(keys) ->
            case length(keys) do
              1 ->
                exclude(query, :select)

              2 ->
                query
                |> exclude(:select)
                |> select(
                  [q],
                  fragment(
                    "COUNT(DISTINCT ROW(?, ?))::INT",
                    field(q, ^Enum.at(keys, 0)),
                    field(q, ^Enum.at(keys, 1))
                  )
                )

              3 ->
                query
                |> exclude(:select)
                |> select(
                  [q],
                  fragment(
                    "COUNT(DISTINCT ROW(?, ?, ?))::INT",
                    field(q, ^Enum.at(keys, 0)),
                    field(q, ^Enum.at(keys, 1)),
                    field(q, ^Enum.at(keys, 2))
                  )
                )

              4 ->
                query
                |> exclude(:select)
                |> select(
                  [q],
                  fragment(
                    "COUNT(DISTINCT ROW(?, ?, ?, ?))::INT",
                    field(q, ^Enum.at(keys, 0)),
                    field(q, ^Enum.at(keys, 1)),
                    field(q, ^Enum.at(keys, 2)),
                    field(q, ^Enum.at(keys, 3))
                  )
                )

              5 ->
                query
                |> exclude(:select)
                |> select(
                  [q],
                  fragment(
                    "COUNT(DISTINCT ROW(?, ?, ?, ?, ?))::INT",
                    field(q, ^Enum.at(keys, 0)),
                    field(q, ^Enum.at(keys, 1)),
                    field(q, ^Enum.at(keys, 2)),
                    field(q, ^Enum.at(keys, 3)),
                    field(q, ^Enum.at(keys, 4))
                  )
                )

              _ ->
                query
                |> exclude(:select)
                |> select(count("*"))
            end
        end
      end

      defp count(query) do
        query
        |> exclude(:limit)
        |> exclude(:offset)
        |> subquery()
        |> select(count("*"))
      end
    end
  end
end
