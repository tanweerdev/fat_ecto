defmodule FatEcto.Builder.FatQueryBuildable do
  @moduledoc """
  Builds Ecto queries after filtering fields based on user-provided filterable and overrideable fields.

  This module extends FatDynamicsBuildable to work directly with Ecto queries, applying conditions
  to an existing query rather than just building dynamics.

  ## Options
  - `filterable`: A map of fields and their allowed operators. Example:
      [
        id: ["$EQUAL", "$NOT_EQUAL"],
        name: ["$ILIKE"]
      ]
  - `overrideable`: A list of fields that can be overridden. Example:
      ["name", "phone"]
  - `ignoreable`: A map of fields and their ignoreable values. Example:
      [
        "name" => ["%%", "", [], nil],
        "phone" => ["%%", "", [], nil]
      ]

  ## Example Usage
      defmodule FatEcto.Query.MyApp.HospitalQuery do
        use FatEcto.Builder.FatQueryBuildable,
          filterable: [
            id: ["$EQUAL", "$NOT_EQUAL"]
          ],
          overrideable: ["name", "phone"],
          ignoreable: [
            name: ["%%", "", [], nil],
            phone: ["%%", "", [], nil]
          ]

        import Ecto.Query

        def override_buildable(query, "name", "$ILIKE", value) do
          from(q in query, where: ilike(fragment("(?)::TEXT", q.name), ^value)
        end

        def override_buildable(query, "phone", "$ILIKE", value) do
          from(q in query, where: ilike(fragment("(?)::TEXT", q.phone), ^value)
        end

        def override_buildable(query, _, _, _) do
          query
        end

        # Optional: Override after_buildable to perform custom processing on the final query
        def after_buildable(query) do
          IO.puts("Do something on final query")
          query
        end
      end
  """

  alias FatEcto.Builder.FatDynamicsBuilder
  alias FatEcto.Builder.FatHelper

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
    quote do
      @behaviour FatEcto.Builder.FatQueryBuildable
      @options unquote(options)
      @filterable @options[:filterable] || []
      @overrideable_fields @options[:overrideable] || []
      @ignoreable @options[:ignoreable] || []
      import Ecto.Query

      # Ensure at least one of `filterable` or `overrideable` fields option is provided.
      if @filterable == [] and @overrideable_fields == [] do
        raise CompileError,
          description: """
          You must provide at least one of `filterable` or `overrideable` option.
          Example:
            use FatEcto.Builder.FatQueryBuildable,
              filterable: [id: ["$EQUAL", "$NOT_EQUAL"]],
              overrideable: [:name, :phone]
          """
      end

      unless (is_list(@filterable) || is_nil(@filterable)) and
               (is_list(@overrideable_fields) || is_nil(@overrideable_fields)) do
        raise CompileError,
          description: """
          Format for `filterable` or `overrideable` fields should be in expected format.
          Example:
            use FatEcto.Builder.FatQueryBuildable,
              filterable: [id: ["$EQUAL", "$NOT_EQUAL"]],
              overrideable: [:name, :phone]
          """
      end

      @filterable_fields FatEcto.FatHelper.filterable_opt_to_map(@filterable)
      @ignoreable_fields_values FatEcto.FatHelper.keyword_list_to_map(@ignoreable)

      @doc """
      Builds a query after filtering fields based on the provided parameters.

      ### Parameters
        - `query`: The base Ecto query to build upon
        - `where_params`: A map of fields and their filtering operators (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
        - `build_options`: Additional options for query building.

      ### Returns
        - The query with filtering applied.
      """
      @spec build(Ecto.Query.t(), map() | nil, keyword()) :: Ecto.Query.t()
      def build(query, where_params \\ nil, build_options \\ [])

      def build(query, where_params, _build_options) when is_map(where_params) do
        # Remove ignoreable fields from the params
        where_params_ignoreables_removed =
          FatHelper.remove_ignoreable_fields(where_params, @ignoreable_fields_values)

        # Only keep filterable fields in params
        filterable_params =
          FatHelper.filter_filterable_fields(
            where_params_ignoreables_removed,
            @filterable_fields,
            @overrideable_fields
          )

        # Build dynamics with the override_buildable function as the callback
        dynamics =
          FatDynamicsBuilder.build(
            filterable_params,
            &dynamics_override_callback(query, &1, &2, &3, &4)
          )

        # Apply the dynamics to the query
        query =
          if dynamics do
            from(q in query, where: ^dynamics)
          else
            query
          end

        # Apply after_buildable callback
        after_buildable(query)
      end

      def build(query, _where_params, _build_options) do
        after_buildable(query)
      end

      # Helper function to adapt the dynamics override callback to work with queries
      defp dynamics_override_callback(query, dynamics, field, operator, value) do
        case override_buildable(query, field, operator, value) do
          new_query when is_struct(new_query, Ecto.Query) ->
            # If the override modified the query directly, we need to return nil for the dynamics
            # since the condition was already applied to the query
            nil

          _ ->
            # Fall back to default dynamics behavior
            dynamics
        end
      end

      @doc """
      Default implementation of `override_buildable/4`.

      This function can be overridden by the using module to implement custom query filtering logic.
      """
      def override_buildable(query, _field, _operator, _value), do: query

      @doc """
      Default implementation of after_buildable/1.

      This function can be overridden by the using module to perform custom processing on the final query.
      """
      def after_buildable(query), do: query

      defoverridable override_buildable: 4
      defoverridable after_buildable: 1
    end
  end
end
