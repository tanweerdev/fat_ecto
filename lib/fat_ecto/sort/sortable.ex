defmodule FatEcto.Sort.Sortable do
  @moduledoc """
  Builds order_by expressions with pure functions (no macro injection).

  This module extracts all logic into callable functions, with a thin __using__ macro
  for backward compatibility.

  ## Direct Usage (New Way - Call functions directly)

      opts = [
        sortable: [name: "*", age: ["$ASC", "$DESC"]],
        overrideable: ["custom_sort"]
      ]

      override_fn = fn field, operator ->
        case {field, operator} do
          {"custom_sort", "$ASC"} ->
            import Ecto.Query
            {:asc, dynamic([q], q.name)}
          _ ->
            nil
        end
      end

      params = %{"name" => "$DESC", "custom_sort" => "$ASC"}
      order_by_exprs = FatEcto.Sort.Sortable.build(params, opts, override_fn)

  ## Macro Usage (Backward Compatible)

      defmodule MyApp.UserSort do
        use FatEcto.Sort.Sortable,
          sortable: [email: "*", name: ["$ASC", "$DESC"], age: ["$DESC"]],
          overrideable: ["custom_field"]

        import Ecto.Query

        def override_sortable("custom_field", "$ASC") do
          {:asc, dynamic([u], fragment("?->>'custom_field'", u.metadata))}
        end

        def override_sortable("custom_field", "$DESC") do
          {:desc, dynamic([u], fragment("?->>'custom_field'", u.metadata))}
        end

        def override_sortable(_field, _operator), do: nil
      end

      order_by = MyApp.UserSort.build(%{"email" => "$DESC", "custom_field" => "$ASC"})
      query = from(u in User, order_by: ^order_by)
      Repo.all(query)
  """
  alias FatEcto.SharedHelper
  alias FatEcto.Sort.Helper
  alias FatEcto.Sort.Sorter

  # ============================================================================
  # PUBLIC API - Pure Functions
  # ============================================================================

  @doc """
  Builds order_by expressions for the given sort parameters.

  ## Parameters
  - `sort_params` - Map of fields and their sort operators
  - `opts` - Configuration options:
    - `:sortable` - List of sortable fields and operators (e.g., `[name: "*", age: ["$ASC"]]`)
    - `:overrideable` - List of overrideable field names (e.g., `["custom_sort"]`)
  - `override_callback` - Function to handle overrideable fields `(field, operator) -> order_expr | nil`

  ## Returns
  - List of order_by expressions
  """
  @spec build(
          map() | nil,
          keyword(),
          (String.t(), String.t() -> Sorter.order_expr() | nil)
        ) :: [Sorter.order_expr()]
  def build(sort_params, opts, override_callback)

  def build(sort_params, opts, override_callback) when is_map(sort_params) do
    # Validate options
    validate_options!(opts)

    # Build configuration
    config = build_config(opts)

    # Filter standard sortable fields
    standard_params = Helper.filter_sortable_fields(sort_params, config.sortable_fields)

    # Filter overrideable fields
    override_params = Map.take(sort_params, config.overrideable_fields)

    # Process standard fields
    standard_orders = Sorter.build_order_by(standard_params)

    # Process override fields with callback
    override_orders =
      Enum.flat_map(override_params, fn {field, operator} ->
        case override_callback.(field, operator) do
          order when not is_nil(order) -> [order]
          _ -> []
        end
      end)

    standard_orders ++ override_orders
  end

  def build(_sort_params, _opts, _override_callback), do: []

  # ============================================================================
  # BACKWARD COMPATIBLE MACRO
  # ============================================================================

  @doc """
  Callback for handling custom sorting logic.

  Should return `{direction, dynamic}` tuple or nil if not handling the field.
  """
  @callback override_sortable(field :: String.t(), operator :: String.t()) :: Sorter.order_expr() | nil

  defmacro __using__(options \\ []) do
    # Validate options at compile time
    validate_options!(options)

    quote location: :keep do
      @behaviour FatEcto.Sort.Sortable
      @options unquote(options)
      @sortable @options[:sortable] || []
      @overrideable_fields @options[:overrideable] || []

      @sortable_opts [
        sortable: @sortable,
        overrideable: @overrideable_fields
      ]

      @doc """
      Builds order_by expressions for the given sort parameters.
      Delegates to FatEcto.Sort.Sortable.build/3
      """
      @spec build(map()) :: [FatEcto.Sort.Sorter.order_expr()]
      def build(sort_params) when is_map(sort_params) do
        unquote(__MODULE__).build(
          sort_params,
          @sortable_opts,
          &override_sortable/2
        )
      end

      def build(_), do: []

      # Only define default override_sortable/2 if no overrideable fields are configured
      if @overrideable_fields == [] do
        @doc """
        Default implementation of `override_sortable/2` when no overrideable fields are configured.
        """
        @impl true
        def override_sortable(_field, _operator), do: nil

        defoverridable override_sortable: 2
      end
    end
  end

  # ============================================================================
  # PRIVATE HELPER FUNCTIONS
  # ============================================================================

  defp validate_options!(options) do
    sortable = Keyword.get(options, :sortable, [])
    overrideable = Keyword.get(options, :overrideable, [])

    # Ensure at least one of `sortable` or `overrideable` fields option is provided
    if sortable == [] and overrideable == [] do
      raise ArgumentError, """
      At least one of `sortable` or `overrideable` must be provided.
      Example:
        use FatEcto.Sort.Sortable,
          sortable: [id: "$ASC"],
          overrideable: ["custom_field"]
      """
    end

    # Validate format of sortable and overrideable
    unless (is_list(sortable) || is_nil(sortable)) and
             (is_list(overrideable) || is_nil(overrideable)) do
      raise ArgumentError, """
      Format for `sortable` or `overrideable` should be in expected format.
      Example:
        use FatEcto.Sort.Sortable,
          sortable: [id: "$ASC"],
          overrideable: ["custom_field"]
      """
    end

    :ok
  end

  defp build_config(opts) do
    sortable = Keyword.get(opts, :sortable, [])
    overrideable_fields = Keyword.get(opts, :overrideable, [])

    %{
      sortable_fields: SharedHelper.filterable_opt_to_map(sortable),
      overrideable_fields: overrideable_fields
    }
  end
end
