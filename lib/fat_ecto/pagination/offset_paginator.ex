defmodule FatEcto.Pagination.OffsetPaginator do
  @moduledoc """
  Offset-based pagination with pure functions (no macro injection).

  This module extracts all logic into callable functions, with a thin __using__ macro
  for backward compatibility.

  ## Application Configuration

  You can configure global pagination settings in your config.exs:

      config :fat_ecto, FatEcto.Pagination.OffsetPaginator,
        repo: MyApp.Repo,
        default_limit: 10,
        max_limit: 200

  **Note:** `default_limit` and `max_limit` are required - you must configure them either globally
  or pass them explicitly. There are no hardcoded defaults.

  Configuration priority (highest to lowest):
  1. Explicit options passed to function/macro
  2. Global application config (config.exs)

  ## Direct Usage (New Way - Call functions directly)

      query = from(u in User)
      opts = [default_limit: 20, max_limit: 100]
      {:ok, result} = FatEcto.Pagination.OffsetPaginator.paginate(query, params, MyRepo, opts)

  ## Macro Usage (Backward Compatible)

      defmodule MyPaginator do
        use FatEcto.Pagination.OffsetPaginator,
          repo: MyRepo,
          default_limit: 20,
          max_limit: 100
      end

      {:ok, result} = MyPaginator.paginate(query, params)
  """

  import Ecto.Query

  @default_page 1
  @min_limit 1

  # ============================================================================
  # PUBLIC API - Pure Functions
  # ============================================================================

  @doc """
  Paginates a query using offset-based pagination.

  ## Parameters
  - `query` - Ecto query to paginate
  - `params` - Pagination parameters (keyword list or map)
  - `repo` - Ecto repository module
  - `opts` - Configuration options
    - `:default_limit` - Default page size (default: 20)
    - `:max_limit` - Maximum allowed page size (default: 100)
    - `:count_records_fn` - Custom count function (default: uses built-in)

  ## Returns
  - `{:ok, %{entries: [...], metadata: %{...}}}` on success
  - `{:error, reason}` on validation error
  """
  @spec paginate(Ecto.Query.t(), keyword() | map(), module(), keyword()) ::
          {:ok, %{entries: list(), metadata: map()}} | {:error, String.t()}
  def paginate(query, params, repo, opts \\ []) do
    params = normalize_params(params)
    # Merge global config with explicit opts (explicit opts take priority)
    global_config = Application.get_env(:fat_ecto, __MODULE__, [])
    merged_opts = Keyword.merge(global_config, opts)
    config = build_config(merged_opts)

    with {:ok, validated} <- validate_params(params, config),
         {:ok, total_count} <- fetch_total_count(query, params, repo, config),
         entries <- fetch_entries(query, validated, repo) do
      metadata = build_metadata(validated, total_count, length(entries))
      {:ok, %{entries: entries, metadata: metadata}}
    end
  end

  @doc """
  Validates pagination parameters.

  ## Examples

      iex> OffsetPaginator.validate_params(%{page: 1, limit: 20}, default_limit: 20, max_limit: 100)
      {:ok, %{offset: 0, limit: 20}}
  """
  @spec validate_params(keyword() | map(), keyword()) ::
          {:ok, %{offset: non_neg_integer(), limit: pos_integer()}} | {:error, String.t()}
  def validate_params(params, opts \\ []) do
    params = normalize_params(params)
    config = build_config(opts)

    with {:ok, limit} <- validate_limit(params, config),
         {:ok, offset} <- validate_offset(params, limit) do
      {:ok, %{offset: offset, limit: limit}}
    end
  end

  @doc """
  Counts records in a query with smart handling of complex queries.

  Handles:
  - DISTINCT expressions
  - GROUP BY clauses
  - Composite primary keys
  - Subqueries
  """
  @spec count_records(Ecto.Query.t(), module()) :: non_neg_integer()
  def count_records(query, repo) do
    count_query = build_count_query(query)

    case count_query.select do
      nil ->
        # Simple count - use aggregate
        primary_keys = FatEcto.SharedHelper.get_primary_keys(count_query)
        field = if primary_keys && length(primary_keys) > 0, do: hd(primary_keys), else: :id
        repo.aggregate(count_query, :count, field)

      _ ->
        # Complex count with select - execute query
        repo.one(count_query) || 0
    end
  rescue
    _ -> 0
  end

  # ============================================================================
  # BACKWARD COMPATIBLE MACRO
  # ============================================================================

  @callback paginate(Ecto.Query.t(), keyword() | map()) ::
              {:ok, %{entries: list(), metadata: map()}} | {:error, String.t()}
  @callback validate_params(keyword() | map()) ::
              {:ok, %{offset: non_neg_integer(), limit: pos_integer()}} | {:error, String.t()}
  @callback count_records(Ecto.Query.t()) :: non_neg_integer()

  defmacro __using__(opts) do
    repo = Keyword.get(opts, :repo)
    explicit_config = Keyword.drop(opts, [:repo])
    paginator_module = __MODULE__

    quote location: :keep do
      @behaviour FatEcto.Pagination.OffsetPaginator

      # Store explicit config and repo
      @explicit_config unquote(explicit_config)
      @explicit_repo unquote(repo)

      @doc """
      Paginates the given query.
      Delegates to OffsetPaginator.paginate/4
      """
      @impl true
      def paginate(query, params \\ []) do
        # Read global config at runtime and merge with explicit options
        global_config = Application.get_env(:fat_ecto, unquote(paginator_module), [])
        merged_config = Keyword.merge(global_config, @explicit_config)

        # Get repo: explicit > global config
        repo =
          @explicit_repo || Keyword.get(global_config, :repo) ||
            raise ArgumentError, """
            repo is required for #{__MODULE__}. You can either:
            1. Pass it explicitly: use FatEcto.Pagination.OffsetPaginator, repo: MyApp.Repo
            2. Configure it globally: config :fat_ecto, FatEcto.Pagination.OffsetPaginator, repo: MyApp.Repo
            """

        unquote(paginator_module).paginate(query, params, repo, merged_config)
      end

      @doc """
      Validates pagination parameters.
      Delegates to OffsetPaginator.validate_params/2
      """
      @impl true
      def validate_params(params) do
        # Read global config at runtime and merge with explicit options
        global_config = Application.get_env(:fat_ecto, unquote(paginator_module), [])
        merged_config = Keyword.merge(global_config, @explicit_config)

        unquote(paginator_module).validate_params(params, merged_config)
      end

      @doc """
      Counts records in a query.
      Delegates to OffsetPaginator.count_records/2
      Can be overridden for custom counting logic.
      """
      @impl true
      def count_records(query) do
        # Get repo: explicit > global config
        global_config = Application.get_env(:fat_ecto, unquote(paginator_module), [])
        repo = @explicit_repo || Keyword.get(global_config, :repo)

        unquote(paginator_module).count_records(query, repo)
      end

      defoverridable count_records: 1
    end
  end

  # ============================================================================
  # PRIVATE HELPER FUNCTIONS
  # ============================================================================

  defp build_config(opts) do
    default_limit = Keyword.get(opts, :default_limit)
    max_limit = Keyword.get(opts, :max_limit)

    unless default_limit do
      raise ArgumentError, """
      default_limit is required. You can either:
      1. Pass it explicitly: paginate(query, params, repo, default_limit: 20)
      2. Configure it globally: config :fat_ecto, FatEcto.Pagination.OffsetPaginator, default_limit: 20
      """
    end

    unless max_limit do
      raise ArgumentError, """
      max_limit is required. You can either:
      1. Pass it explicitly: paginate(query, params, repo, max_limit: 100)
      2. Configure it globally: config :fat_ecto, FatEcto.Pagination.OffsetPaginator, max_limit: 100
      """
    end

    [
      default_limit: default_limit,
      max_limit: max_limit,
      count_records_fn: Keyword.get(opts, :count_records_fn)
    ]
  end

  defp normalize_params(params) when is_list(params), do: Map.new(params)
  defp normalize_params(params) when is_map(params), do: params

  defp validate_limit(params, config) do
    default_limit = config[:default_limit]
    max_limit = config[:max_limit]

    limit =
      get_param_value(params, :page_size, "page_size", nil) ||
        get_param_value(params, :limit, "limit", default_limit)

    limit = parse_integer(limit, default_limit)

    cond do
      limit < @min_limit -> {:error, "limit must be at least #{@min_limit}"}
      limit > max_limit -> {:error, "limit exceeds maximum allowed value of #{max_limit}"}
      true -> {:ok, limit}
    end
  end

  defp validate_offset(params, limit) do
    page = get_param_value(params, :page, "page", nil)

    if page do
      page = parse_integer(page, @default_page)

      if page < 1 do
        {:error, "page must be at least 1"}
      else
        {:ok, (page - 1) * limit}
      end
    else
      offset = get_param_value(params, :offset, "offset", 0)
      offset = parse_integer(offset, 0)

      if offset < 0 do
        {:error, "offset must be non-negative"}
      else
        {:ok, offset}
      end
    end
  end

  defp fetch_total_count(query, params, repo, config) do
    include_count = get_param_value(params, :include_total_count, "include_total_count", true)

    if include_count do
      count =
        if config[:count_records_fn] do
          config[:count_records_fn].(query, repo)
        else
          count_records(query, repo)
        end

      {:ok, count}
    else
      {:ok, nil}
    end
  rescue
    e -> {:error, "Failed to count records: #{inspect(e)}"}
  end

  defp fetch_entries(query, %{offset: offset, limit: limit}, repo) do
    query
    |> offset(^offset)
    |> limit(^limit)
    |> repo.all()
  end

  defp build_metadata(%{offset: offset, limit: limit}, total_count, entries_count) do
    current_page = div(offset, limit) + 1
    total_pages = if total_count && limit > 0, do: ceil(total_count / limit), else: nil

    base_metadata = %{
      offset: offset,
      page_size: limit,
      current_page: current_page,
      start_cursor: offset,
      end_cursor: offset + entries_count,
      entries_count: entries_count
    }

    if total_count do
      Map.merge(base_metadata, %{
        total_count: total_count,
        total_pages: total_pages,
        has_next_page: offset + entries_count < total_count,
        has_previous_page: offset > 0,
        is_first_page: offset == 0,
        is_last_page: offset + entries_count >= total_count
      })
    else
      Map.merge(base_metadata, %{
        total_count: nil,
        total_pages: nil,
        has_next_page: entries_count == limit,
        has_previous_page: offset > 0
      })
    end
  end

  defp build_count_query(query) do
    query
    |> exclude(:limit)
    |> exclude(:offset)
    |> exclude(:order_by)
    |> exclude(:preload)
    |> aggregate_query()
    |> exclude(:distinct)
    |> distinct(true)
  end

  # Handle DISTINCT expressions
  defp aggregate_query(%{distinct: %{expr: [_ | _]}} = query) do
    query
    |> exclude(:select)
    |> wrap_in_count_subquery()
  end

  # Handle GROUP BY
  defp aggregate_query(
         %{
           group_bys: [
             %Ecto.Query.QueryExpr{expr: [{{:., [], [{:&, [], [source_index]}, field]}, [], []} | _]} | _
           ]
         } = query
       ) do
    query
    |> exclude(:select)
    |> select([{x, source_index}], struct(x, ^[field]))
    |> wrap_in_count_subquery()
  end

  # Default case - handle based on primary keys
  defp aggregate_query(query) do
    primary_keys = FatEcto.SharedHelper.get_primary_keys(query)

    case primary_keys do
      nil ->
        query |> exclude(:select) |> select(count("*"))

      keys when is_list(keys) ->
        handle_primary_keys_aggregate(query, keys)
    end
  end

  defp handle_primary_keys_aggregate(query, keys) do
    case length(keys) do
      1 ->
        exclude(query, :select)

      2 ->
        query
        |> exclude(:select)
        |> select(
          [q],
          fragment("COUNT(DISTINCT ROW(?, ?))::INT", field(q, ^Enum.at(keys, 0)), field(q, ^Enum.at(keys, 1)))
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

  defp wrap_in_count_subquery(query) do
    query
    |> exclude(:limit)
    |> exclude(:offset)
    |> subquery()
    |> select(count("*"))
  end

  defp get_param_value(params, atom_key, string_key, default) do
    cond do
      Map.has_key?(params, atom_key) -> Map.get(params, atom_key)
      Map.has_key?(params, string_key) -> Map.get(params, string_key)
      true -> default
    end
  end

  defp parse_integer(value, _default) when is_integer(value), do: value

  defp parse_integer(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end

  defp parse_integer(_, default), do: default
end
