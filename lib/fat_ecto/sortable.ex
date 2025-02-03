defmodule FatEcto.FatQuery.Sortable do
  @moduledoc """
  Provides functionality to sort Ecto queries based on user-defined rules.

  This module allows sorting queries using predefined default fields (handled by `FatOrderBy`)
  and custom fields (handled by a fallback function).

  ## Usage

      defmodule MyApp.SortQuery do
        <!-- needed if you are writing queries in override_sortable -->
        import Ecto.Query
        use FatEcto.FatQuery.Sortable,
          sortable_fields: %{"id" => "$asc", "name" => ["$asc", "$desc"]},
          overrideable_fields: ["custom_field"]

        @impl true
        def override_sortable(query, field, operator) do
          case {field, operator} do
            {"custom_field", "$asc"} ->
              from(q in query, order_by: [asc: fragment("?::jsonb->>'custom_field'", q)])
            _ ->
              query
          end
        end
      end

  ## Example

      query = from(u in User)
      sort_params = %{"id" => "$asc", "name" => "$desc", "custom_field" => "$asc"}
      MyApp.SortQuery.build(query, sort_params)

  This will sort the query by `id` in ascending order, `name` in descending order, and apply custom sorting for `custom_field`.
  """

  alias FatEcto.FatQuery.FatOrderBy

  @doc """
  Callback for handling custom sorting logic.

  This function is called for fields defined in `overrideable_fields`. The default behavior is to return the query,
  but it can be overridden by the using module.
  """
  @callback override_sortable(
              query :: Ecto.Query.t(),
              field :: String.t() | atom(),
              operator :: String.t()
            ) :: Ecto.Query.t()

  defmacro __using__(options \\ []) do
    quote do
      @behaviour FatEcto.FatQuery.Sortable
      @options unquote(options)
      @sortable_fields @options[:sortable_fields] || %{}
      @overrideable_fields @options[:overrideable_fields] || []
      alias FatEcto.FatQuery.SortableHelper

      # Raise a compile-time error if both sortable_fields and overrideable_fields are empty.
      if @sortable_fields == %{} and @overrideable_fields == [] do
        raise ArgumentError, """
        At least one of `sortable_fields` or `overrideable_fields` must be provided.
        Example:
          use FatEcto.FatQuery.Sortable,
            sortable_fields: %{"id" => "$asc"},
            overrideable_fields: ["custom_field"]
        """
      end

      # Ensure `override_sortable/3` is implemented if `overrideable_fields` are provided.
      # if @overrideable_fields != [] do
      #   unless Module.defines?(__MODULE__, {:override_sortable, 3}) do
      #     raise CompileError,
      #       description: """
      #       You must implement the `override_sortable/3` callback when `overrideable_fields` are provided.
      #       Example:
      #         def override_sortable(query, field, operator) do
      #           # Your custom logic here
      #           query
      #         end
      #       """
      #   end
      # end

      @doc """
      Applies sorting to the query based on the provided parameters.

      ### Parameters
        - `queryable`: The Ecto query to which sorting will be applied.
        - `sort_params`: A map of fields and their sorting operators (e.g., `%{"field" => "$asc"}`).
        - `options`: Additional options for query building (passed to `FatOrderBy`).

      ### Returns
        - The query with sorting applied.
      """
      @spec build(Ecto.Query.t(), map(), keyword()) :: Ecto.Query.t()
      def build(queryable, sort_params, options \\ []) do
        # Step 1: Filter sortable_fields and prepare params for FatOrderBy
        order_by_params = SortableHelper.filter_sortable_fields(sort_params, @sortable_fields)

        # Step 2: Apply sorting using FatOrderBy
        queryable = FatOrderBy.build_order_by(queryable, order_by_params, options)

        # Step 3: Apply custom sorting for overrideable_fields
        # Filter sort_params to only include fields in @overrideable_fields
        # TODO: we need to fix this to allow for multiple operators inside $or
        override_params =
          Enum.filter(sort_params, fn {field, _operator} -> field in @overrideable_fields end)

        # Apply custom sorting only if there are fields to override
        Enum.reduce(override_params, queryable, fn {field, operator}, query ->
          override_sortable(query, field, operator)
        end)
      end

      @doc """
      Default implementation of `override_sortable/3`.

      This function can be overridden by the using module to implement custom sorting logic.
      """
      @spec override_sortable(Ecto.Query.t(), String.t() | atom(), String.t()) :: Ecto.Query.t()
      def override_sortable(query, _field, _operator), do: query

      defoverridable override_sortable: 3
    end
  end
end
