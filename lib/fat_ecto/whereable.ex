defmodule FatEcto.FatQuery.Whereable do
  @moduledoc """
  Builds queries after filtering fields based on user-provided filterable and overrideable fields.

  This module provides functionality to filter Ecto queries using predefined filterable fields (handled by `FatWhere`)
  and overrideable fields (handled by a fallback function).

  ## Options
  - `filterable_fields`: A map of fields and their allowed operators. Example:
      %{
        "id" => ["$eq", "$neq"],
        "name" => ["$ilike"]
      }
  - `overrideable_fields`: A list of fields that can be overridden. Example:
      ["name", "phone"]
  - `ignoreable_fields_values`: A map of fields and their ignoreable values. Example:
      %{
        "name" => ["%%", "", [], nil],
        "phone" => ["%%", "", [], nil]
      }

  ## Example Usage
      defmodule MyApp.HospitalFilter do
        use FatEcto.FatQuery.Whereable,
          filterable_fields: %{
            "id" => ["$eq", "$neq"]
          },
          overrideable_fields: ["name", "phone"],
          ignoreable_fields_values: %{
            "name" => ["%%", "", [], nil],
            "phone" => ["%%", "", [], nil]
          }

        import Ecto.Query

        def override_whereable(query, "name", "$ilike", value) do
          where(query, [r], ilike(fragment("(?)::TEXT", r.name), ^value))
        end

        def override_whereable(query, "phone", "$ilike", value) do
          where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^value))
        end

        def override_whereable(query, _, _, _) do
          query
        end
      end
  """

  alias FatEcto.FatQuery.FatWhere

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
      @all_operators "*"

      # Ensure at least one of `filterable_fields` or `overrideable_fields` is provided.
      if @filterable_fields == %{} and @overrideable_fields == [] do
        raise CompileError,
          description: """
          You must provide at least one of `filterable_fields` or `overrideable_fields`.
          Example:
            use FatEcto.FatQuery.Whereable,
              filterable_fields: %{"id" => ["$eq", "$neq"]},
              overrideable_fields: ["name", "phone"]
          """
      end

      # Ensure `override_whereable/4` is implemented if `overrideable_fields` are provided.
      # if @overrideable_fields != [] do
      #   unless Module.defines?(__MODULE__, {:override_whereable, 4}) do
      #     raise CompileError,
      #       description: """
      #       You must implement the `override_whereable/4` callback when `overrideable_fields` are provided.
      #       Example:
      #         def override_whereable(query, field, operator, value) do
      #           # Your custom logic here
      #           query
      #         end
      #       """
      #   end
      # end

      @doc """
      Builds a query after filtering fields based on the provided parameters.

      ### Parameters
        - `queryable`: The Ecto query to which filtering will be applied.
        - `where_params`: A map of fields and their filtering operators (e.g., `%{"field" => %{"$eq" => "value"}}`).
        - `build_options`: Additional options for query building (passed to `FatWhere`).

      ### Returns
        - The query with filtering applied.
      """
      def build(queryable, where_params, build_options \\ []) do
        filtered_where_params = remove_ignoreable_fields(where_params)

        # Filter filterable fields
        filterable_params = filter_filterable_fields(filtered_where_params, @filterable_fields)

        # Filter overrideable fields
        overrideable_params = filter_overrideable_fields(filtered_where_params, @overrideable_fields)

        queryable
        |> FatWhere.build_where(filterable_params, build_options)
        |> apply_overrideable_filters(overrideable_params)
      end

      @doc """
      Default implementation of `override_whereable/4`.

      This function can be overridden by the using module to implement custom filtering logic.
      """
      def override_whereable(query, _field, _operator, _value), do: query

      # Removes fields with ignoreable values from the parameters.
      defp remove_ignoreable_fields(params) do
        Enum.reduce(params, params, fn {field, value}, acc ->
          case @ignoreable_fields_values[field] do
            nil -> acc
            ignoreable_values -> remove_ignoreable_values(acc, field, value, ignoreable_values)
          end
        end)
      end

      # Removes specific values from a field's operators.
      defp remove_ignoreable_values(params, field, value, ignoreable_values) when is_map(value) do
        Enum.reduce(value, params, fn {operator, value}, acc ->
          if ignoreable_value?(value, ignoreable_values) do
            acc |> pop_in([field, operator]) |> elem(1)
          else
            acc
          end
        end)
      end

      # Checks if a value is ignoreable for a given ignoreable_values.
      defp ignoreable_value?(value, ignoreable_values) when is_list(ignoreable_values) do
        value in ignoreable_values
      end

      defp ignoreable_value?(value, ignoreable_value) when is_binary(ignoreable_value) do
        value == ignoreable_value
      end

      # Filters filterable fields based on the provided filterable_fields map.
      defp filter_filterable_fields(params, filterable_fields) when filterable_fields == %{}, do: %{}

      defp filter_filterable_fields(params, filterable_fields) do
        Enum.reduce(params, %{}, fn {field, value}, acc ->
          case filterable_fields[field] do
            # Skip fields not defined in filterable_fields
            nil -> acc
            allowed_operators -> filter_field_operators(acc, field, value, allowed_operators)
          end
        end)
      end

      # Filters operators for a specific field based on allowed operators.
      defp filter_field_operators(acc, field, value, allowed_operators) when is_map(value) do
        filtered_value =
          Enum.reduce(value, %{}, fn {operator, value}, acc_value ->
            if operator_matches?(operator, allowed_operators) do
              Map.put(acc_value, operator, value)
            else
              acc_value
            end
          end)

        if filtered_value != %{} do
          Map.put(acc, field, filtered_value)
        else
          acc
        end
      end

      # Filters overrideable fields based on the provided overrideable_fields list.
      defp filter_overrideable_fields(params, overrideable_fields) when overrideable_fields == [],
        do: []

      defp filter_overrideable_fields(params, overrideable_fields) do
        Enum.reduce(params, [], fn {field, value}, acc ->
          if field in overrideable_fields do
            Enum.reduce(value, acc, fn {operator, value}, acc ->
              if ignoreable_value?(value, @ignoreable_fields_values[field] || []) do
                acc
              else
                [%{field: field, operator: operator, value: value} | acc]
              end
            end)
          else
            acc
          end
        end)
      end

      # Checks if an operator matches the allowed or overrideable operators.
      defp operator_matches?(operator, operators) do
        is_list(operators) and (operator in operators or @all_operators in operators)
      end

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
end
