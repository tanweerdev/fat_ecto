defmodule FatEcto.Pagination.V2Paginator do
  @moduledoc """
  Behaviour and implementation for robust Ecto query pagination.

  ## Usage

      defmodule MyApp.MyPaginator do
        use FatEcto.Pagination.V2Paginator,
          repo: MyApp.Repo,
          default_limit: 20,
          max_limit: 100

        # Optional overrides
        def count_records(query) do
          # Custom counting logic
        end
      end
  """
  alias FatEcto.SharedHelper

  @doc """
  Required callback for counting records in a query.
  """
  @callback count_records(Ecto.Query.t()) :: integer()

  @doc """
  Required callback for paginating a query.
  """
  @callback paginate(Ecto.Query.t(), map() | keyword()) ::
              {:ok, %{records: [struct()], meta: map()}} | {:error, String.t()}

  defmacro __using__(opts \\ []) do
    quote location: :keep do
      @behaviour FatEcto.Pagination.V2Paginator

      import Ecto.Query
      alias Ecto.Query.Builder

      @repo Keyword.fetch!(unquote(opts), :repo)
      @default_limit Keyword.get(unquote(opts), :default_limit, 20)
      @max_limit Keyword.get(unquote(opts), :max_limit, 100)

      @doc """
      Paginates the query and returns records with metadata.

      ## Parameters
      - `query`: Ecto query to paginate
      - `params`: Map or keyword list with :limit and :skip/:page parameters

      ## Returns
      `{:ok, %{records: [map], meta: map}}` or `{:error, reason}`

      Meta includes:
      - :total - total records count
      - :limit - records per page
      - :skip - records skipped
      - :pages - total pages
      """

      @impl true
      def paginate(query, params \\ %{}) do
        {limit, skip} = get_pagination_params(params)

        with {:ok, total} <- safe_count(query),
             records <- get_records(query, skip, limit) do
          {:ok,
           %{
             records: records,
             meta: %{
               total: total,
               limit: limit,
               skip: skip,
               pages: calculate_pages(total, limit)
             }
           }}
        end
      end

      defp get_pagination_params(params) do
        {skip, params} = FatEcto.Pagination.Helper.get_skip_value(params)
        {limit, _params} = FatEcto.Pagination.Helper.get_limit_value(params, unquote(opts))
        {limit, skip}
      end

      defp safe_count(query) do
        {:ok, count_records(query)}
      rescue
        e -> {:error, "Failed to count records: #{inspect(e)}"}
      end

      @impl true
      def count_records(query) do
        query
        |> exclude_pagination_clauses()
        |> exclude_order_group_and_preloads()
        |> maybe_handle_composite_keys()
        |> @repo.aggregate(:count)
      end

      defp exclude_pagination_clauses(query) do
        query
        |> exclude(:limit)
        |> exclude(:offset)
      end

      defp exclude_order_group_and_preloads(query) do
        query
        |> exclude(:order_by)
        |> exclude(:group_by)
        |> exclude(:preload)
        |> exclude(:select)
      end

      defp maybe_handle_composite_keys(query) do
        case SharedHelper.get_primary_keys(query) do
          nil -> query
          [single_key] -> query
          keys -> apply_composite_key_distinct(query, keys)
        end
      end

      defp apply_composite_key_distinct(query, keys) do
        # First create a subquery with just the key fields
        subquery =
          query
          |> select([q], map(q, ^keys))
          |> subquery()

        # Then count the distinct combinations
        from(s in subquery,
          select: count(fragment("DISTINCT (?)", ^map_fields(keys)))
        )
      end

      defp map_fields(keys) do
        keys
        |> Enum.map(fn key ->
          {:., [], [{:&, [], [0]}, key]}
        end)
        |> Enum.reduce(fn field, acc ->
          {:concat, [], [acc, {:||, [], [",", field]}]}
        end)
      end

      defp get_records(query, skip, limit) do
        query
        |> offset(^skip)
        |> limit(^limit)
        |> @repo.all()
      end

      defp calculate_pages(total, limit) do
        (total / limit) |> Float.ceil() |> trunc()
      end

      defoverridable paginate: 2, count_records: 1
    end
  end
end
