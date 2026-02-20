defmodule FatEcto.Sort.Sortable do
  @moduledoc """
  Provides functionality to define sortable fields with override support.

  ## Example Usage

      defmodule MyApp.UserSort do
        use FatEcto.Sort.Sortable,
          sortable: [email: "*", name: ["$ASC", "$DESC"]],
          overrideable: ["custom_field"]

        @impl true
        def override_sortable("custom_field", "$ASC") do
          {:asc, dynamic([u], fragment("?->>'custom_field'", u.metadata))}
        end

        def override_sortable("custom_field", "$DESC") do
          {:desc, dynamic([u], fragment("?->>'custom_field'", u.metadata))}
        end

        def override_sortable(_field, _operator) do
          nil
        end
      end

      # Usage:
      order_by = MyApp.UserSort.build(%{"email" => "$DESC", "custom_field" => "$ASC"})
      query = from(u in User, order_by: ^order_by)
  """
  alias FatEcto.Sort.Helper
  alias FatEcto.Sort.Sorter

  @doc """
  Callback for handling custom sorting logic.

  Should return `{direction, dynamic}` tuple or nil if not handling the field.
  """
  @callback override_sortable(field :: String.t(), operator :: String.t()) :: Sorter.order_expr() | nil

  defmacro __using__(options \\ []) do
    sortable = options[:sortable] || []

    {_direct_sortable, join_sorts} = FatEcto.SharedHelper.separate_filterables(sortable)
    sort_join_filters_map = FatEcto.SharedHelper.build_join_filters_map(join_sorts)
    sortable_fields = FatEcto.SharedHelper.flatten_sortable_to_map(sortable)
    sort_aliases = FatEcto.SharedHelper.build_field_aliases(sortable)

    quote do
      @behaviour FatEcto.Sort.Sortable
      @options unquote(options)
      @sortable @options[:sortable] || []
      @overrideable_fields @options[:overrideable] || []

      # Raise a compile-time error if both sortable and overrideable options are empty.
      if @sortable == [] and @overrideable_fields == [] do
        raise ArgumentError, """
        At least one of `sortable_fields` or `overrideable_fields` must be provided.
        Example:
          use FatEcto.Sort.Sortable,
            sortable: [id: "$ASC"],
            overrideable: ["custom_field"]
        """
      end

      unless (is_list(@sortable) || is_nil(@sortable)) and
               (is_list(@overrideable_fields) || is_nil(@overrideable_fields)) do
        raise ArgumentError, """
        Please send `sortable` and `overrideable` in expected format see below example.
        Example:
          use FatEcto.Sort.Sortable,
            sortable: [id: "$ASC"],
            overrideable: ["custom_field"]
        """
      end

      @sortable_fields unquote(Macro.escape(sortable_fields))
      @sort_aliases unquote(Macro.escape(sort_aliases))
      @sort_join_filters_map unquote(Macro.escape(sort_join_filters_map))

      @doc """
      Builds order_by expressions for the given sort parameters.
      Only processes fields defined in either sortable or overrideable lists.
      """
      @spec build(map()) :: [Sorter.order_expr()]
      def build(sort_params) when is_map(sort_params) do
        # Filter standard sortable fields first
        standard_params = Helper.filter_sortable_fields(sort_params, @sortable_fields)

        # Filter overrideable fields (only those explicitly listed)
        override_params = Map.take(sort_params, @overrideable_fields)

        # Process standard fields (with alias resolution and join binding support)
        standard_orders = Sorter.build_order_by(standard_params, @sort_aliases, @sort_join_filters_map)

        # Process override fields with callback
        override_orders =
          Enum.flat_map(override_params, fn {field, operator} ->
            case override_sortable(field, operator) do
              order when not is_nil(order) -> [order]
              _ -> []
            end
          end)

        standard_orders ++ override_orders
      end

      def build(_), do: []

      @doc """
      Default implementation returns nil (no custom ordering).
      """
      @spec override_sortable(String.t(), String.t()) :: Sorter.order_expr() | nil
      def override_sortable(_field, _operator), do: nil
      defoverridable override_sortable: 2
    end
  end
end
