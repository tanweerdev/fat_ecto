defmodule FatEcto.FatQuery.Whereable do
  @moduledoc """
  Builds queries after filtering fields based on user-provided filterable and overrideable fields.

  This module provides functionality to filter Ecto queries using predefined filterable fields (handled by `Builder`)
  and overrideable fields (handled by a fallback function).

  ## Options
  - `filterable_fields`: A map of fields and their allowed operators. Example:
      %{
        "id" => ["$EQUAL", "$NOT_EQUAL"],
        "name" => ["$ILIKE"]
      }
  - `overrideable_fields`: A list of fields that can be overridden. Example:
      ["name", "phone"]
  - `ignoreable_fields_values`: A map of fields and their ignoreable values. Example:
      %{
        "name" => ["%%", "", [], nil],
        "phone" => ["%%", "", [], nil]
      }

  ## Example Usage
      defmodule FatEcto.FatHospitalFilter do
        use FatEcto.FatQuery.Whereable,
          filterable_fields: %{
            "id" => ["$EQUAL", "$NOT_EQUAL"]
          },
          overrideable_fields: ["name", "phone"],
          ignoreable_fields_values: %{
            "name" => ["%%", "", [], nil],
            "phone" => ["%%", "", [], nil]
          }

        import Ecto.Query

        def override_whereable(query, "name", "$ILIKE", value) do
          where(query, [r], ilike(fragment("(?)::TEXT", r.name), ^value))
        end

        def override_whereable(query, "phone", "$ILIKE", value) do
          where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^value))
        end

        def override_whereable(query, _, _, _) do
          query
        end
      end
  """

  alias FatEcto.FatQuery.Builder

  @doc """
  Callback for handling custom filtering logic for overrideable fields.

  This function acts as a fallback for overrideable fields. The default behavior is to return the query,
  but it can be overridden by the using module.
  """
  @callback override_whereable(
              query :: Ecto.Query.t(),
              field :: String.t() | atom(),
              operator :: String.t(),
              value :: any()
            ) :: Ecto.Query.t()

  defmacro __using__(options \\ []) do
    quote do
      @behaviour FatEcto.FatQuery.Whereable
      @options unquote(options)
      @filterable_fields @options[:filterable_fields] || %{}
      @overrideable_fields @options[:overrideable_fields] || []
      @ignoreable_fields_values @options[:ignoreable_fields_values] || %{}
      alias FatEcto.FatQuery.WhereableHelper
      # def using_options, do: @options
      # # Defer the repo check to runtime
      # @after_compile FatEcto.FatQuery.Whereable

      # Ensure at least one of `filterable_fields` or `overrideable_fields` is provided.
      if @filterable_fields == %{} and @overrideable_fields == [] do
        raise CompileError,
          description: """
          You must provide at least one of `filterable_fields` or `overrideable_fields`.
          Example:
            use FatEcto.FatQuery.Whereable,
              filterable_fields: %{"id" => ["$EQUAL", "$NOT_EQUAL"]},
              overrideable_fields: ["name", "phone"]
          """
      end

      @doc """
      Builds a query after filtering fields based on the provided parameters.

      ### Parameters
        - `where_params`: A map of fields and their filtering operators (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
        - `build_options`: Additional options for query building (passed to `Builder`).

      ### Returns
        - The query with filtering applied.
      """
      @spec build(map() | nil, keyword()) :: %Ecto.Query.DynamicExpr{} | nil
      def build(where_params \\ nil, build_options \\ [])

      def build(where_params, build_options) when is_map(where_params) do
        filtered_where_params =
          WhereableHelper.remove_ignoreable_fields(where_params, @ignoreable_fields_values)

        # Filter filterable fields
        combined_params =
          WhereableHelper.filter_filterable_fields(filtered_where_params, @filterable_fields)

        # Filter overrideable fields
        overrideable_params =
          WhereableHelper.filter_overrideable_fields(
            where_params,
            @overrideable_fields,
            @ignoreable_fields_values
          )

        combined_params
        |> Builder.build_query(build_options)
        |> apply_overrideable_filters(overrideable_params)
      end

      def build(_where_params, _build_options) do
        nil
      end

      @doc """
      Default implementation of `override_whereable/4`.

      This function can be overridden by the using module to implement custom filtering logic.
      """
      def override_whereable(query, _field, _operator, _value), do: query

      # Applies custom filtering for overrideable fields using the fallback function.
      defp apply_overrideable_filters(query, overrideable_params) do
        Enum.reduce(overrideable_params, query, fn %{
                                                     field: field,
                                                     operator: operator,
                                                     value: value
                                                   },
                                                   query ->
          override_whereable(query, field, operator, value)
        end)
      end

      defoverridable override_whereable: 4
    end
  end

  # TODO: This callback doesnt really work as we have default implementation already provided
  # @doc """
  # Callback function that runs after the module is compiled.
  # """
  # def __after_compile__(%{module: module}, _bytecode) do
  #   options = module.using_options()

  #   # Ensure `override_whereable/4` is implemented if `overrideable_fields` are provided.
  #   IO.inspect("options: #{inspect(options)}")
  #   if options[:overrideable_fields] != [] do
  #     unless Module.defines?(module, {:override_whereable, 4}) do
  #       raise CompileError,
  #         description: """
  #         You must implement the `override_whereable/4` callback when `overrideable_fields` are provided.
  #         Example:
  #           def override_whereable(query, field, operator, value) do
  #             # Your custom logic here
  #             query
  #           end
  #         """
  #     end
  #   end
  # end
end
