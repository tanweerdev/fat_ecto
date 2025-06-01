defmodule FatEcto.Query.Dynamics.Buildable do
  @moduledoc """
  Builds queries after filtering fields based on user-provided filterable and overrideable fields.

  This module provides functionality to filter Ecto queries using predefined filterable fields (handled by `Builder`)
  and overrideable fields (handled by a fallback function).

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
            ) :: Ecto.Query.dynamic_expr()

  @doc """
  Callback for performing custom processing on the final dynamics.

  This function is called at the end of the `build/2` function. The default behavior is to return the dynamics,
  but it can be overridden by the using module.
  """
  @callback after_buildable(dynamics :: Ecto.Query.dynamic_expr()) :: Ecto.Query.dynamic_expr()

  defmacro __using__(options \\ []) do
    quote do
      @behaviour FatEcto.Query.Dynamics.Buildable
      @options unquote(options)
      @filterable @options[:filterable] || []
      @overrideable_fields @options[:overrideable] || []
      @ignoreable @options[:ignoreable] || []
      alias FatEcto.Query.Helper
      # def using_options, do: @options
      # # Defer the repo check to runtime
      # @after_compile FatEcto.Query.Dynamics.Buildable

      # Ensure at least one of `filterable` or `overrideable` fields option is provided.
      if @filterable == [] and @overrideable_fields == [] do
        raise CompileError,
          description: """
          You must provide at least one of `filterable` or `overrideable` option.
          Example:
            use FatEcto.Query.Dynamics.Buildable,
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
            use FatEcto.Query.Dynamics.Buildable,
              filterable: [id: ["$EQUAL", "$NOT_EQUAL"]],
              overrideable: [:name, :phone]
          """
      end

      @filterable_fields FatEcto.SharedHelper.filterable_opt_to_map(@filterable)
      @ignoreable_fields_values FatEcto.SharedHelper.keyword_list_to_map(@ignoreable)

      @doc """
      Builds dynamics after filtering fields based on the provided parameters.

      ### Parameters
        - `where_params`: A map of fields and their filtering operators (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
        - `build_options`: Additional options for dynamics building (passed to `Builder`).

      ### Returns
        - The dynamics with filtering applied.
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

        # Build dynamics with the override_buildable function as the callback
        dynamics =
          Builder.build(
            filterable_params,
            &override_buildable/3,
            @overrideable_fields
          )

        # Apply after_buildable callback
        after_buildable(dynamics)
      end

      def build(_where_params, _build_options) do
        after_buildable(nil)
      end

      @doc """
      Default implementation of `override_buildable/3`.

      This function can be overridden by the using module to implement custom filtering logic.
      """
      def override_buildable(_field, _operator, _value), do: nil

      @doc """
      Default implementation of after_buildable/1.

      This function can be overridden by the using module to perform custom processing on the final dynamics.
      """
      def after_buildable(dynamics), do: dynamics

      defoverridable override_buildable: 3
      defoverridable after_buildable: 1
    end
  end

  # TODO: This callback doesnt really work as we have default implementation already provided
  # @doc """
  # Callback function that runs after the module is compiled.
  # """
  # def __after_compile__(%{module: module}, _bytecode) do
  #   options = module.using_options()

  #   # Ensure `override_buildable/3` is implemented if `overrideable_fields` are provided.
  #   IO.inspect("options: #{inspect(options)}")
  #   if options[:overrideable_fields] != [] do
  #     unless Module.defines?(module, {:override_buildable, 3}) do
  #       raise CompileError,
  #         description: """
  #         You must implement the `override_buildable/3` callback when `overrideable_fields` are provided.
  #         Example:
  #           def override_buildable(field, operator, value) do
  #             # Your custom logic here
  #             dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
  #           end
  #         """
  #     end
  #   end
  # end
end
