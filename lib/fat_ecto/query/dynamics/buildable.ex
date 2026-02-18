defmodule FatEcto.Query.Dynamics.Buildable do
  @moduledoc """
  Builds queries after filtering fields based on user-provided filterable and overrideable fields.

  This module provides functionality to filter Ecto queries using predefined filterable fields (handled by `Builder`)
  and overrideable fields (handled by a fallback function).

  ## Options
  - `filterable`: A keyword list of fields and their allowed operators. Supports nested structures
      for filtering on joined/associated tables. Example:
      [
        id: ["$EQUAL", "$NOT_EQUAL"],
        name: ["$ILIKE"],
        # Nested = join filter (association name must match `as:` binding)
        classifications: [
          subject_id: ["$EQUAL"],
          grade_id: ["$EQUAL", "$IN"]
        ]
      ]
  - `overrideable`: A list of fields that can be overridden. Example:
      ["name", "phone"]
  - `ignoreable`: A map of fields and their ignoreable values. Example:
      [
        "name" => ["%%", "", [], nil],
        "phone" => ["%%", "", [], nil]
      ]
  - `default_dynamic`: When set to `:return_true`, returns `dynamic([q], true)` instead of `nil`
      when no dynamics are built. Example: `default_dynamic: :return_true`

  ## Join Filters (Nested Filterable)

  When a filterable entry has a keyword list as its value (instead of a list of operator strings),
  it's treated as a join filter. The key becomes the expected named binding (via `as:` option in join).

      use FatEcto.Query.Dynamics.Buildable,
        filterable: [
          title: ["$ILIKE"],                    # Direct filter on main table
          classifications: [                     # Join filter on :classifications binding
            subject_id: ["$EQUAL"],
            grade_id: ["$EQUAL", "$IN"]
          ]
        ]

  The caller must provide the join with matching `as:` binding:

      Video
      |> join(:inner, [v], c in assoc(v, :classifications), as: :classifications)
      |> where(^dynamics)

  Join filters support all standard operators: `$EQUAL`, `$NOT_EQUAL`, `$IN`, `$NOT_IN`,
  `$LIKE`, `$ILIKE`, `$GT`, `$GTE`, `$LT`, `$LTE`, `$NULL`, `$NOT_NULL`.

  Join filters also work seamlessly with `$OR` and `$AND` operators:

      %{
        "$OR" => [
          %{"subject_id" => %{"$EQUAL" => "math-uuid"}},
          %{"grade_id" => %{"$EQUAL" => "grade-10-uuid"}}
        ]
      }

  ## Global Configuration
  You can configure the default behavior for all Buildable modules in your config:

      # config/config.exs
      config :fat_ecto, :default_dynamic, :return_true

  This will make all Buildable modules return `dynamic([q], true)` when no filters are applied,
  unless explicitly overridden at the module level with `default_dynamic: nil`.

  ## Example Usage
      defmodule FatEcto.HospitalDynamicsBuilder do
        use FatEcto.Query.Dynamics.Buildable,
          filterable: [
            id: ["$EQUAL", "$NOT_EQUAL"]
          ],
          overrideable: ["name", "phone"],
          ignoreable: [
            name: ["%%", "", [], nil],
            phone: ["%%", "", [], nil]
          ]

        import Ecto.Query

        def override_buildable("name", "$ILIKE", value) do
          dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
        end

        def override_buildable("phone", "$ILIKE", value) do
          dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
        end

        def override_buildable(_field, _operator, _value) do
          nil
        end

        # Optional: Override after_buildable to perform custom processing on the final dynamics
        def after_buildable(dynamics) do
          IO.puts("Do something on final Dynamics")
          dynamics
        end
      end
  """

  alias FatEcto.Query.Dynamics.Builder

  @doc """
  Callback for handling custom filtering logic for overrideable fields.

  This function acts as a fallback for overrideable fields. The default behavior is to return nil,
  but it can be overridden by the using module.
  """
  @callback override_buildable(
              field :: String.t() | atom(),
              operator :: String.t(),
              value :: any()
            ) :: Ecto.Query.dynamic_expr() | nil

  @doc """
  Callback for performing custom processing on the final dynamics.

  This function is called at the end of the `build/2` function. The default behavior is to return the dynamics,
  but it can be overridden by the using module.
  """
  @callback after_buildable(dynamics :: Ecto.Query.dynamic_expr() | nil) :: any()

  defmacro __using__(options \\ []) do
    # Get the filterable option
    filterable = options[:filterable] || []

    # Separate join filters for building join_filters_map
    {_direct_filterable, join_filters} =
      FatEcto.SharedHelper.separate_filterables(filterable)

    # Build the join_filters_map (field_name => binding) for Builder
    join_filters_map = FatEcto.SharedHelper.build_join_filters_map(join_filters)

    # Extract join filter field names (for tracking)
    join_filter_fields = FatEcto.SharedHelper.extract_join_filter_fields(join_filters)

    # Flatten all filterables into a single map (handles both direct and join)
    # Direct filters get their operators, join filter fields get "*" wildcard
    filterable_fields = FatEcto.SharedHelper.flatten_filterable_to_map(filterable)

    # Build field aliases map (api_name => schema_field) for aliased fields
    field_aliases = FatEcto.SharedHelper.build_field_aliases(filterable)

    # Pre-compute ignoreable fields map
    ignoreable_fields_values = FatEcto.SharedHelper.keyword_list_to_map(options[:ignoreable] || [])

    quote do
      @behaviour FatEcto.Query.Dynamics.Buildable
      @options unquote(Macro.escape(options))
      @join_filters unquote(Macro.escape(join_filters))
      @join_filters_map unquote(Macro.escape(join_filters_map))
      @base_overrideable_fields @options[:overrideable] || []

      # Join filter fields are stored separately (not added to overrideable)
      # Builder handles them directly via join_filters_map
      @join_filter_fields unquote(Macro.escape(join_filter_fields))
      @overrideable_fields @base_overrideable_fields

      # Pre-computed filterable, ignoreable, and alias maps
      @filterable_fields unquote(Macro.escape(filterable_fields))
      @field_aliases unquote(Macro.escape(field_aliases))
      @ignoreable_fields_values unquote(Macro.escape(ignoreable_fields_values))

      # Get default_dynamic option: module option takes precedence over global config
      @default_dynamic_option (case Keyword.get(@options, :default_dynamic) do
                                 nil -> Application.compile_env(:fat_ecto, :default_dynamic, nil)
                                 value -> value
                               end)

      alias FatEcto.Query.Helper
      import Ecto.Query

      # Ensure at least one of `filterable` or `overrideable` fields option is provided.
      if @filterable_fields == %{} and @base_overrideable_fields == [] do
        raise CompileError,
          description: """
          You must provide at least one of `filterable` or `overrideable` option.
          Example:
            use FatEcto.Query.Dynamics.Buildable,
              filterable: [id: ["$EQUAL", "$NOT_EQUAL"]],
              overrideable: [:name, :phone]
          """
      end

      @doc """
      Builds dynamics after filtering fields based on the provided parameters.

      ### Parameters
        - `where_params`: A map of fields and their filtering operators (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
        - `build_options`: Additional options for dynamics building (passed to `Builder`).

      ### Returns
        - The dynamics with filtering applied (or the result from `after_buildable/1` callback).
      """
      @spec build(map() | nil, keyword()) :: Ecto.Query.dynamic_expr() | nil
      def build(where_params \\ nil, build_options \\ [])

      def build(where_params, build_options) when is_map(where_params) do
        # Remove ignoreable fields from the params
        where_params_ignoreables_removed =
          Helper.remove_ignoreable_fields(where_params, @ignoreable_fields_values)

        # Only keep filterable fields in params
        filterable_params =
          Helper.filter_filterable_fields(
            where_params_ignoreables_removed,
            @filterable_fields,
            @overrideable_fields
          )

        # Build dynamics with:
        # - override_buildable as callback for overrideable fields
        # - join_filters_map for join filter fields (handled by JoinOperatorApplier)
        # - field_aliases for resolving API names to schema fields
        dynamics =
          Builder.build(
            filterable_params,
            &override_buildable/3,
            @overrideable_fields,
            @join_filters_map,
            @field_aliases
          )

        # Apply default_dynamic if nil and configured
        dynamics = apply_default_dynamic(dynamics)

        # Apply after_buildable callback
        after_buildable(dynamics)
      end

      def build(_where_params, _build_options) do
        # Apply default_dynamic if configured
        dynamics = apply_default_dynamic(nil)
        after_buildable(dynamics)
      end

      # Helper to apply default_dynamic when dynamics is nil
      # Only generate the special case if the option is actually :return_true
      if @default_dynamic_option == :return_true do
        defp apply_default_dynamic(nil) do
          dynamic([q], true)
        end

        defp apply_default_dynamic(dynamics), do: dynamics
      else
        # Default behavior - just pass through
        defp apply_default_dynamic(dynamics), do: dynamics
      end

      # Only define default override_buildable/3 if no overrideable fields are configured
      if @overrideable_fields == [] do
        @doc """
        Default implementation of `override_buildable/3` when no overrideable fields are configured.
        """
        def override_buildable(_field, _operator, _value), do: nil

        defoverridable override_buildable: 3
      end

      @doc """
      Default implementation of after_buildable/1.

      This function can be overridden by the using module to perform custom processing on the final dynamics.
      """
      def after_buildable(dynamics), do: dynamics

      defoverridable after_buildable: 1
    end
  end
end
