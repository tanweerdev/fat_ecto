defmodule FatEcto.Pagination.CursorPaginator do
  @moduledoc """
  Cursor-based pagination with pure functions (no macro injection).

  This module extracts all logic into callable functions, with a thin __using__ macro
  for backward compatibility.

  ## Application Configuration

  You can configure global pagination settings in your config.exs:

      config :fat_ecto, FatEcto.Pagination.CursorPaginator,
        repo: MyApp.Repo,
        default_limit: 10,
        max_limit: 200

  **Note:** `default_limit` and `max_limit` are required - you must configure them either globally
  or pass them explicitly. There are no hardcoded defaults.

  Configuration priority (highest to lowest):
  1. Explicit options passed to function/macro
  2. Global application config (config.exs)

  ## Direct Usage (New Way - Call functions directly)

      query = from(u in User, order_by: [asc: u.id])
      opts = [default_limit: 20, max_limit: 100]
      {:ok, result} = FatEcto.Pagination.CursorPaginator.paginate(
        query,
        %{cursor_fields: [:id], first: 10},
        MyRepo,
        opts
      )

  ## Macro Usage (Backward Compatible)

      defmodule MyPaginator do
        use FatEcto.Pagination.CursorPaginator,
          repo: MyRepo,
          default_limit: 20,
          max_limit: 100
      end

      {:ok, result} = MyPaginator.paginate(query, cursor_fields: [:id], first: 10)
  """

  import Ecto.Query

  @min_limit 1

  # ============================================================================
  # PUBLIC API - Pure Functions
  # ============================================================================

  @doc """
  Paginates a query using cursor-based pagination.

  ## Parameters
  - `query` - Ecto query to paginate (must include ORDER BY clause)
  - `params` - Pagination parameters (keyword list or map)
  - `repo` - Ecto repository module
  - `opts` - Configuration options
    - `:default_limit` - Default page size (default: 20)
    - `:max_limit` - Maximum allowed page size (default: 100)

  ## Returns
  - `{:ok, %{edges: [...], page_info: %{...}, total_count: ...}}` on success
  - `{:error, reason}` on validation error
  """
  @spec paginate(Ecto.Query.t(), keyword() | map(), module(), keyword()) ::
          {:ok, %{edges: list(), page_info: map(), total_count: non_neg_integer() | nil}}
          | {:error, String.t()}
  def paginate(query, params, repo, opts \\ []) do
    params = normalize_params(params)
    # Merge global config with explicit opts (explicit opts take priority)
    global_config = Application.get_env(:fat_ecto, __MODULE__, [])
    merged_opts = Keyword.merge(global_config, opts)
    config = build_config(merged_opts)

    with {:ok, validated_params} <- validate_cursor_params(params, config),
         {:ok, filtered_query} <- apply_cursor_filters(query, validated_params),
         records <- fetch_records(filtered_query, validated_params, repo),
         {:ok, total_count} <- fetch_total_count(query, params, repo) do
      edges = build_edges(records, validated_params.cursor_fields, validated_params.limit)
      page_info = build_page_info(edges, records, validated_params)

      {:ok, %{edges: edges, page_info: page_info, total_count: total_count}}
    end
  end

  @doc """
  Encodes a cursor from a record and cursor fields.
  """
  @spec encode_cursor(struct() | nil, list(atom())) :: String.t() | nil
  def encode_cursor(nil, _cursor_fields), do: nil

  def encode_cursor(record, cursor_fields) do
    cursor_data =
      cursor_fields
      |> Enum.map(fn field ->
        value = Map.get(record, field)
        {field, serialize_value(value)}
      end)
      |> Map.new()

    cursor_data
    |> :erlang.term_to_binary()
    |> Base.url_encode64(padding: false)
  end

  @doc """
  Decodes a cursor string.
  """
  @spec decode_cursor(String.t() | nil) :: {:ok, map() | nil} | {:error, String.t()}
  def decode_cursor(nil), do: {:ok, nil}

  def decode_cursor(cursor) when is_binary(cursor) do
    case Base.url_decode64(cursor, padding: false) do
      {:ok, binary} ->
        try do
          cursor_data = :erlang.binary_to_term(binary, [:safe])

          if is_map(cursor_data) do
            deserialized =
              cursor_data
              |> Enum.map(fn {k, v} -> {k, deserialize_value(v)} end)
              |> Map.new()

            {:ok, deserialized}
          else
            {:error, "Invalid cursor format"}
          end
        rescue
          ArgumentError -> {:error, "Invalid cursor encoding"}
        end

      :error ->
        {:error, "Invalid cursor encoding"}
    end
  end

  # ============================================================================
  # BACKWARD COMPATIBLE MACRO
  # ============================================================================

  @callback paginate(Ecto.Query.t(), keyword() | map()) ::
              {:ok, %{edges: list(), page_info: map(), total_count: non_neg_integer() | nil}}
              | {:error, String.t()}
  @callback encode_cursor(struct(), list(atom())) :: String.t()
  @callback decode_cursor(String.t()) :: {:ok, map()} | {:error, String.t()}

  defmacro __using__(opts) do
    repo = Keyword.get(opts, :repo)
    explicit_config = Keyword.drop(opts, [:repo])
    paginator_module = __MODULE__

    quote location: :keep do
      @behaviour FatEcto.Pagination.CursorPaginator

      # Store explicit config and repo
      @explicit_config unquote(explicit_config)
      @explicit_repo unquote(repo)

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
            1. Pass it explicitly: use FatEcto.Pagination.CursorPaginator, repo: MyApp.Repo
            2. Configure it globally: config :fat_ecto, FatEcto.Pagination.CursorPaginator, repo: MyApp.Repo
            """

        unquote(paginator_module).paginate(query, params, repo, merged_config)
      end

      @impl true
      def encode_cursor(record, cursor_fields) do
        unquote(paginator_module).encode_cursor(record, cursor_fields)
      end

      @impl true
      def decode_cursor(cursor) do
        unquote(paginator_module).decode_cursor(cursor)
      end
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
      2. Configure it globally: config :fat_ecto, FatEcto.Pagination.CursorPaginator, default_limit: 20
      """
    end

    unless max_limit do
      raise ArgumentError, """
      max_limit is required. You can either:
      1. Pass it explicitly: paginate(query, params, repo, max_limit: 100)
      2. Configure it globally: config :fat_ecto, FatEcto.Pagination.CursorPaginator, max_limit: 100
      """
    end

    [
      default_limit: default_limit,
      max_limit: max_limit
    ]
  end

  defp normalize_params(params) when is_list(params), do: Map.new(params)
  defp normalize_params(params) when is_map(params), do: params

  # Validation
  defp validate_cursor_params(params, config) do
    with {:ok, cursor_fields} <- validate_cursor_fields(params),
         {:ok, direction, limit} <- validate_direction_and_limit(params, config),
         {:ok, cursor_value} <- extract_cursor_value(params, direction) do
      {:ok,
       %{
         cursor_fields: cursor_fields,
         direction: direction,
         limit: limit,
         cursor_value: cursor_value
       }}
    end
  end

  defp validate_cursor_fields(params) do
    case Map.get(params, :cursor_fields) || Map.get(params, "cursor_fields") do
      nil ->
        {:error, "cursor_fields is required"}

      fields when is_list(fields) ->
        if length(fields) > 0 do
          {:ok, fields}
        else
          {:error, "cursor_fields cannot be empty"}
        end

      _ ->
        {:error, "cursor_fields must be a list"}
    end
  end

  defp validate_direction_and_limit(params, config) do
    first = get_param_value(params, :first, "first", nil)
    last = get_param_value(params, :last, "last", nil)

    cond do
      not is_nil(first) and not is_nil(last) ->
        {:error, "Cannot specify both 'first' and 'last'"}

      not is_nil(first) ->
        validate_limit_value(first, :forward, config)

      not is_nil(last) ->
        validate_limit_value(last, :backward, config)

      true ->
        {:ok, :forward, config[:default_limit]}
    end
  end

  defp validate_limit_value(value, direction, config) do
    limit = parse_integer(value, nil)
    max_limit = config[:max_limit]

    cond do
      is_nil(limit) -> {:error, "Limit must be a valid integer"}
      limit < @min_limit -> {:error, "Limit must be at least #{@min_limit}"}
      limit > max_limit -> {:error, "Limit exceeds maximum allowed value of #{max_limit}"}
      true -> {:ok, direction, limit}
    end
  end

  defp extract_cursor_value(params, :forward) do
    {:ok, get_param_value(params, :after, "after", nil)}
  end

  defp extract_cursor_value(params, :backward) do
    {:ok, get_param_value(params, :before, "before", nil)}
  end

  # Cursor filtering
  defp apply_cursor_filters(query, %{cursor_value: nil}), do: {:ok, query}

  defp apply_cursor_filters(query, %{
         cursor_value: cursor_value,
         cursor_fields: cursor_fields,
         direction: direction
       }) do
    with {:ok, decoded_cursor} <- decode_cursor(cursor_value) do
      operator = if direction == :forward, do: :>, else: :<
      filtered_query = build_cursor_condition(query, decoded_cursor, cursor_fields, operator)
      {:ok, filtered_query}
    end
  rescue
    e -> {:error, "Failed to apply cursor filter: #{inspect(e)}"}
  end

  defp build_cursor_condition(query, cursor_value, [field], operator) do
    value = Map.get(cursor_value, field)
    condition = build_single_field_condition(field, value, operator)
    from(q in query, where: ^condition)
  end

  defp build_cursor_condition(query, cursor_value, cursor_fields, operator)
       when length(cursor_fields) > 1 do
    condition = build_composite_condition(cursor_fields, cursor_value, operator)
    from(q in query, where: ^condition)
  end

  defp build_single_field_condition(field, value, :>) do
    dynamic([q], field(q, ^field) > ^value)
  end

  defp build_single_field_condition(field, value, :<) do
    dynamic([q], field(q, ^field) < ^value)
  end

  defp build_composite_condition(cursor_fields, cursor_value, operator) do
    cursor_fields
    |> Enum.with_index()
    |> Enum.reduce(nil, fn {field, index}, acc ->
      current_value = Map.get(cursor_value, field)
      equality_conditions = build_equality_conditions(cursor_fields, cursor_value, index)
      comparison = build_comparison(field, current_value, operator)
      condition = dynamic([q], ^equality_conditions and ^comparison)
      combine_conditions(acc, condition)
    end)
  end

  defp build_equality_conditions(cursor_fields, cursor_value, up_to_index) do
    cursor_fields
    |> Enum.take(up_to_index)
    |> Enum.reduce(dynamic(true), fn field, acc ->
      value = Map.get(cursor_value, field)
      dynamic([q], ^acc and field(q, ^field) == ^value)
    end)
  end

  defp build_comparison(field, value, :>) do
    dynamic([q], field(q, ^field) > ^value)
  end

  defp build_comparison(field, value, :<) do
    dynamic([q], field(q, ^field) < ^value)
  end

  defp combine_conditions(nil, condition), do: condition
  defp combine_conditions(acc, condition), do: dynamic([q], ^acc or ^condition)

  # Record fetching
  defp fetch_records(query, %{limit: limit, direction: :forward}, repo) do
    query
    |> limit(^(limit + 1))
    |> repo.all()
  end

  defp fetch_records(query, %{limit: limit, direction: :backward}, repo) do
    query
    |> reverse_order_by()
    |> limit(^(limit + 1))
    |> repo.all()
    |> Enum.reverse()
  end

  defp reverse_order_by(query) do
    %{query | order_bys: Enum.map(query.order_bys, &reverse_order_by_expr/1)}
  end

  defp reverse_order_by_expr(%{expr: exprs} = order_by) do
    reversed_exprs =
      Enum.map(exprs, fn
        {:asc, field} -> {:desc, field}
        {:desc, field} -> {:asc, field}
        {:asc_nulls_first, field} -> {:desc_nulls_last, field}
        {:asc_nulls_last, field} -> {:desc_nulls_first, field}
        {:desc_nulls_first, field} -> {:asc_nulls_last, field}
        {:desc_nulls_last, field} -> {:asc_nulls_first, field}
        other -> other
      end)

    %{order_by | expr: reversed_exprs}
  end

  # Total count
  defp fetch_total_count(query, params, repo) do
    include_count = get_param_value(params, :include_total_count, "include_total_count", false)

    if include_count do
      count =
        query
        |> exclude(:limit)
        |> exclude(:offset)
        |> exclude(:order_by)
        |> exclude(:preload)
        |> exclude(:select)
        |> repo.aggregate(:count)

      {:ok, count}
    else
      {:ok, nil}
    end
  rescue
    _ -> {:ok, nil}
  end

  # Edge building
  defp build_edges(records, cursor_fields, limit) do
    records
    |> Enum.take(limit)
    |> Enum.map(fn record ->
      %{
        cursor: encode_cursor(record, cursor_fields),
        node: record
      }
    end)
  end

  # Page info
  defp build_page_info(edges, records, %{limit: limit, direction: direction, cursor_value: cursor_value}) do
    has_more = length(records) > limit

    {has_next_page, has_previous_page} =
      case direction do
        :forward ->
          # When going forward: has_next if more records, has_previous if we used a cursor
          {has_more, not is_nil(cursor_value)}

        :backward ->
          # When going backward: has_next if we used a cursor, has_previous if more records
          {not is_nil(cursor_value), has_more}
      end

    %{
      has_next_page: has_next_page,
      has_previous_page: has_previous_page,
      start_cursor: edges |> List.first() |> get_cursor(),
      end_cursor: edges |> List.last() |> get_cursor()
    }
  end

  defp get_cursor(nil), do: nil
  defp get_cursor(%{cursor: cursor}), do: cursor

  # Serialization
  defp serialize_value(%DateTime{} = dt), do: {:datetime, DateTime.to_iso8601(dt)}
  defp serialize_value(%NaiveDateTime{} = ndt), do: {:naive_datetime, NaiveDateTime.to_iso8601(ndt)}
  defp serialize_value(%Date{} = d), do: {:date, Date.to_iso8601(d)}
  defp serialize_value(value), do: {:term, value}

  defp deserialize_value({:datetime, str}) do
    {:ok, datetime, _} = DateTime.from_iso8601(str)
    datetime
  end

  defp deserialize_value({:naive_datetime, str}), do: NaiveDateTime.from_iso8601!(str)
  defp deserialize_value({:date, str}), do: Date.from_iso8601!(str)
  defp deserialize_value({:term, value}), do: value

  # Helpers
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
