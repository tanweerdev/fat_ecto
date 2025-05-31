defmodule FatEcto.FatPaginator do
  @moduledoc """
  Provides pagination functionality for Ecto queries.

  This module can be used to paginate query results by specifying `limit` and `skip` parameters.
  It also supports counting the total number of records for pagination metadata.

  ## Usage

      defmodule Fat.MyContext do
        use FatEcto.FatPaginator, repo: Fat.Repo, default_limit: 10, max_limit: 100

        # Custom functions can be added here
      end

  Now you can use the `paginate/2`, `paginator/3`, and `paginate_get_records/3` functions within `Fat.MyContext`.
  """

  @callback data_query(Ecto.Query.t(), integer(), integer()) :: Ecto.Query.t()
  @callback count_query(Ecto.Query.t()) :: Ecto.Query.t()
  @callback aggregate(Ecto.Query.t()) :: Ecto.Query.t()

  defmacro __using__(options \\ []) do
    quote location: :keep do
      @behaviour FatEcto.FatPaginator

      import Ecto.Query

      @options unquote(options)
      @default_limit Keyword.get(@options, :default_limit, 10)
      @repo @options[:repo]
      @max_limit Keyword.get(@options, :max_limit, 100)
      def repo_option, do: @repo

      # Defer the repo check to runtime
      @after_compile FatEcto.FatPaginator

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

      @doc """
      Applies pagination to the query and returns the query along with pagination metadata.
      """
      def paginator(query, params) do
        limit = params["limit"] || @default_limit
        skip = params["skip"] || 0

        %{
          data_query: data_query,
          skip: skip,
          limit: limit,
          count_query: count_query
        } = paginate(query, skip: skip, limit: limit)

        total_records = count_records(count_query)

        pages = (total_records / limit) |> Float.ceil() |> trunc()

        meta = %{
          skip: skip,
          limit: limit,
          total_records: total_records,
          pages: pages
        }

        {data_query, meta}
      end

      @doc """
      Paginates the query, fetches records, and returns the records along with pagination metadata.
      """
      def paginate_get_records(query, params) do
        {query, meta} = paginator(query, params)
        records = @repo.all(query)
        {records, meta}
      end

      @doc """
      Counts the total number of records for the given count query.
      """
      def count_records(%{select: nil} = count_query) do
        @repo.aggregate(count_query, :count, count_query |> FatEcto.FatHelper.get_primary_keys() |> hd())
      end

      def count_records(count_query) do
        @repo.one(count_query)
      end

      @impl true
      def data_query(query, skip, limit) do
        query
        |> limit(^limit)
        |> offset(^skip)
      end

      @impl true
      def count_query(query) do
        query
        |> exclude(:order_by)
        |> exclude(:preload)
        |> aggregate()
        |> exclude(:distinct)
        |> distinct(true)
      end

      @impl true
      def aggregate(%{distinct: %{expr: [_ | _]}} = query) do
        query
        |> exclude(:select)
        |> count()
      end

      @impl true
      def aggregate(
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

      @impl true
      def aggregate(query) do
        primary_keys = FatEcto.FatHelper.get_primary_keys(query)

        case primary_keys do
          nil ->
            query
            |> exclude(:select)
            |> select(count("*"))

          keys when is_list(keys) ->
            handle_primary_keys(query, keys)
        end
      end

      defp handle_primary_keys(query, keys) do
        case length(keys) do
          1 ->
            exclude(query, :select)

          # |> select([q], fragment("COUNT(DISTINCT ?)::INT", field(q, ^Enum.at(keys, 0))))

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
            raise "Unsupported number of primary keys: #{length(keys)}"
        end
      end

      defp count(query) do
        query
        |> exclude(:limit)
        |> exclude(:offset)
        |> subquery()
        |> select(count("*"))
      end

      defoverridable data_query: 3, count_query: 1, aggregate: 1
    end
  end

  @doc """
  Callback function that runs after the module is compiled.
  """
  @spec __after_compile__(%{:module => atom()}, any()) :: nil
  def __after_compile__(%{module: module}, _bytecode) do
    repo = module.repo_option()

    unless FatEcto.FatHelper.implements_behaviour?(repo, Ecto.Repo) do
      raise ArgumentError, """
      The provided :repo option is not a valid Ecto.Repo.
      Expected a module that implements the Ecto.Repo behaviour, got: #{inspect(repo)}
      """
    end
  end
end
