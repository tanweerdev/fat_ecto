defmodule FatEcto.Query.Buildable do
  @moduledoc """
  Builds Ecto queries with pure functions (no macro injection).

  This module extracts all logic into callable functions, with a thin __using__ macro
  for backward compatibility.

  ## Direct Usage (New Way - Call functions directly)

      opts = [
        filterable: [id: ["$EQUAL"], name: ["$ILIKE"]],
        overrideable: ["custom_field"],
        ignoreable: [name: ["%%", "", nil]]
      ]

      override_fn = fn query, field, operator, value ->
        case {field, operator} do
          {"custom_field", "$EQUAL"} ->
            import Ecto.Query
            from(q in query, where: fragment("UPPER(?)", q.name) == ^String.upcase(value))
          _ ->
            query
        end
      end

      params = %{"id" => %{"$EQUAL" => 1}, "name" => %{"$ILIKE" => "%John%"}}
      query = from(u in User)
      filtered_query = FatEcto.Query.Buildable.build(query, params, opts, override_fn)

  ## Macro Usage (Backward Compatible)

      defmodule MyQueryBuilder do
        use FatEcto.Query.Buildable,
          filterable: [id: ["$EQUAL"], name: ["$ILIKE"]],
          overrideable: ["custom_field"]

        import Ecto.Query

        def override_buildable(query, "custom_field", "$EQUAL", value) do
          from(q in query, where: fragment("UPPER(?)", q.name) == ^String.upcase(value))
        end

        def override_buildable(query, _field, _operator, _value), do: query
      end

      filtered_query = MyQueryBuilder.build(query, params)
  """

  alias FatEcto.Query.Builder
  alias FatEcto.Query.Helper

  # ============================================================================
  # PUBLIC API - Pure Functions
  # ============================================================================

  @doc """
  Builds a query after filtering fields based on the provided parameters.

  ## Parameters
  - `query` - The base Ecto query to build upon
  - `where_params` - Map of fields and their filtering operators
  - `opts` - Configuration options:
    - `:filterable` - List of filterable fields and operators (e.g., `[id: ["$EQUAL"], name: ["$ILIKE"]]`)
    - `:overrideable` - List of overrideable field names (e.g., `["custom_field"]`)
    - `:ignoreable` - List of ignoreable field values (e.g., `[name: ["%%", "", nil]]`)
  - `override_callback` - Function to handle overrideable fields `(query, field, operator, value) -> query`
  - `after_callback` - Optional function to process final query `(query) -> query`

  ## Returns
  - Ecto.Query.t()
  """
  @spec build(
          Ecto.Query.t(),
          map() | nil,
          keyword(),
          (Ecto.Query.t(), String.t() | atom(), String.t(), any() -> Ecto.Query.t()),
          (Ecto.Query.t() -> Ecto.Query.t())
        ) :: Ecto.Query.t()
  def build(query, where_params, opts, override_callback, after_callback \\ &default_after_callback/1)

  def build(query, where_params, opts, override_callback, after_callback) when is_map(where_params) do
    # Validate options
    validate_options!(opts)

    # Build configuration
    config = build_config(opts)

    # Remove ignoreable fields from the params
    where_params_ignoreables_removed =
      Helper.remove_ignoreable_fields(where_params, config.ignoreable_fields_values)

    # Only keep filterable fields in params
    filterable_params =
      Helper.filter_filterable_fields(
        where_params_ignoreables_removed,
        config.filterable_fields,
        config.overrideable_fields
      )

    # Build query with the override callback
    query =
      Builder.build(
        query,
        filterable_params,
        override_callback,
        config.overrideable_fields
      )

    # Apply after_buildable callback
    after_callback.(query)
  end

  def build(query, _where_params, _opts, _override_callback, after_callback) do
    after_callback.(query)
  end

  # ============================================================================
  # BACKWARD COMPATIBLE MACRO
  # ============================================================================

  @doc """
  Callback for handling custom filtering logic for overrideable fields with query support.

  This function acts as a fallback for overrideable fields. The default behavior is to return the query,
  but it can be overridden by the using module.
  """
  @callback override_buildable(
              query :: Ecto.Query.t(),
              field :: String.t() | atom(),
              operator :: String.t(),
              value :: any()
            ) :: Ecto.Query.t()

  @doc """
  Callback for performing custom processing on the final query.

  This function is called at the end of the `build/3` function. The default behavior is to return the query,
  but it can be overridden by the using module.
  """
  @callback after_buildable(query :: Ecto.Query.t()) :: Ecto.Query.t()

  defmacro __using__(options \\ []) do
    # Validate options at compile time
    validate_options!(options)

    quote location: :keep do
      @behaviour FatEcto.Query.Buildable
      @options unquote(options)
      @filterable @options[:filterable] || []
      @overrideable_fields @options[:overrideable] || []
      @ignoreable @options[:ignoreable] || []
      import Ecto.Query

      @buildable_opts [
        filterable: @filterable,
        overrideable: @overrideable_fields,
        ignoreable: @ignoreable
      ]

      @doc """
      Builds a query after filtering fields based on the provided parameters.
      Delegates to FatEcto.Query.Buildable.build/5

      ### Parameters
        - `query`: The base Ecto query to build upon
        - `where_params`: A map of fields and their filtering operators (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
        - `build_options`: Additional options for query building.

      ### Returns
        - The query with filtering applied.
      """
      @spec build(Ecto.Query.t(), map() | nil, keyword()) :: Ecto.Query.t()
      def build(query, where_params \\ nil, build_options \\ [])

      def build(query, where_params, _build_options) do
        unquote(__MODULE__).build(
          query,
          where_params,
          @buildable_opts,
          &override_buildable(&1, &2, &3, &4),
          &after_buildable/1
        )
      end

      # Only define default override_buildable/4 if no overrideable fields are configured
      if @overrideable_fields == [] do
        @doc """
        Default implementation of `override_buildable/4` when no overrideable fields are configured.
        """
        @impl true
        def override_buildable(query, _field, _operator, _value), do: query

        defoverridable override_buildable: 4
      end

      @doc """
      Default implementation of after_buildable/1.

      This function can be overridden by the using module to perform custom processing on the final query.
      """
      @impl true
      def after_buildable(query), do: query

      defoverridable after_buildable: 1
    end
  end

  # ============================================================================
  # PRIVATE HELPER FUNCTIONS
  # ============================================================================

  defp validate_options!(options) do
    filterable = Keyword.get(options, :filterable, [])
    overrideable = Keyword.get(options, :overrideable, [])

    # Ensure at least one of `filterable` or `overrideable` fields option is provided
    if filterable == [] and overrideable == [] do
      raise ArgumentError, """
      You must provide at least one of `filterable` or `overrideable` option.
      Example:
        use FatEcto.Query.Buildable,
          filterable: [id: ["$EQUAL", "$NOT_EQUAL"]],
          overrideable: [:name, :phone]
      """
    end

    # Validate format of filterable and overrideable
    unless (is_list(filterable) || is_nil(filterable)) and
             (is_list(overrideable) || is_nil(overrideable)) do
      raise ArgumentError, """
      Format for `filterable` or `overrideable` fields should be in expected format.
      Example:
        use FatEcto.Query.Buildable,
          filterable: [id: ["$EQUAL", "$NOT_EQUAL"]],
          overrideable: [:name, :phone]
      """
    end

    :ok
  end

  defp build_config(opts) do
    filterable = Keyword.get(opts, :filterable, [])
    overrideable_fields = Keyword.get(opts, :overrideable, [])
    ignoreable = Keyword.get(opts, :ignoreable, [])

    %{
      filterable_fields: FatEcto.SharedHelper.filterable_opt_to_map(filterable),
      overrideable_fields: overrideable_fields,
      ignoreable_fields_values: FatEcto.SharedHelper.keyword_list_to_map(ignoreable)
    }
  end

  defp default_after_callback(query), do: query
end
