defmodule FatEcto.FatQuery.Filterable do
  @moduledoc """
    Build query after filteration of fields on basis of user provided allowed & not_allowd fields from given parameters.
  """

  alias FatEcto.FatQuery.FatWhere

  @doc """
   This function act as fallback for the not_allowed_fields default behaviour is to return query but is overridable
  """
  @callback not_allowed_fields_filter_fallback(
              query :: Ecto.Query.t(),
              not_allowed_field :: String.t() | atom(),
              operator :: String.t(),
              compare_with :: any()
            ) ::
              Ecto.Query.t()

  defmacro(__using__(options \\ [])) do
    quote do
      @behaviour FatEcto.FatQuery.Filterable
      @options unquote(options)
      @fields_allowed @options[:fields_allowed] || %{}
      @fields_not_allowed @options[:fields_not_allowed] || %{}
      @ignoreable_fields_values @options[:ignoreable_fields_values] || %{}
      @all_operators "*"
      @exact_match_operator "$equal"

      def build(queryable, where_params, build_options \\ []) do
        filtered_where_params = remove_fields_with_ignoreable_values(where_params)

        {not_allowed_params, filtered_allowed_params} =
          filtered_where_params
          |> filter_allowed_fields(@fields_allowed)
          |> filter_not_allowed_fields(filtered_where_params, @fields_not_allowed)

        queryable
        |> FatWhere.build_where(filtered_allowed_params, build_options)
        |> build_query_for_not_allowed_fields(not_allowed_params)
      end

      def not_allowed_fields_filter_fallback(query, _field, _operator, _compare_with), do: query

      defp filter_allowed_fields(params, fields_allowed) when fields_allowed == %{},
        do: params

      defp filter_allowed_fields(params, fields_allowed) do
        Enum.reduce(params, params, fn {k, v} = key_value, params ->
          if query_operator = fields_allowed[k],
            do: filter_query_expressions(query_operator, key_value, params, :fields_allowed),
            else: Map.delete(params, k)
        end)
      end

      defp filter_not_allowed_fields(filtered_params, _params, fields_not_allowed)
           when fields_not_allowed == %{} do
        {[], filtered_params}
      end

      defp filter_not_allowed_fields(filtered_params, params, fields_not_allowed) do
        {not_allowed_fields_list, params} =
          Enum.reduce(params, {[], params}, fn {k, v} = key_value, {list, params} ->
            if query_operator = fields_not_allowed[k],
              do: filter_query_expressions(query_operator, key_value, {list, params}, :fields_not_allowed),
              else: {list, params}
          end)

        if @fields_allowed != %{},
          do: {not_allowed_fields_list, filtered_params},
          else: {not_allowed_fields_list, params}
      end

      defp filter_query_expressions(query_operator, param_key_value, params, fields_type)
           when is_binary(query_operator) do
        do_filter_query_expressions([query_operator], param_key_value, params, fields_type)
      end

      defp filter_query_expressions(query_operators, param_key_value, params, fields_type)
           when is_list(query_operators) and length(query_operators) > 0 do
        do_filter_query_expressions(query_operators, param_key_value, params, fields_type)
      end

      defp do_filter_query_expressions(
             query_operators,
             {param_key, param_value},
             {list, params},
             :fields_not_allowed
           )
           when is_map(param_value) do
        Enum.reduce(param_value, {list, params}, fn {operator, compare_with}, {list, params} ->
          if operator in query_operators or @all_operators in query_operators do
            list = [%{"field" => param_key, "operator" => operator, "compare_with" => compare_with}] ++ list
            params = params |> pop_in([param_key, operator]) |> elem(1)
            {list, params}
          else
            {list, params}
          end
        end)
      end

      defp do_filter_query_expressions(
             query_operators,
             {param_key, param_value},
             {list, params},
             :fields_not_allowed
           ) do
        if @exact_match_operator in query_operators or @all_operators in query_operators do
          list =
            [%{"field" => param_key, "operator" => @exact_match_operator, "compare_with" => param_value}] ++
              list

          params = Map.delete(params, param_key)
          {list, params}
        else
          {list, params}
        end
      end

      defp do_filter_query_expressions(query_operators, {param_key, param_value}, params, :fields_allowed)
           when is_map(param_value) do
        Enum.reduce(param_value, params, fn {operator, _compare_with}, params ->
          if operator in query_operators or @all_operators in query_operators,
            do: params,
            else: params |> pop_in([param_key, operator]) |> elem(1)
        end)
      end

      defp do_filter_query_expressions(query_operators, {param_key, param_value}, params, :fields_allowed) do
        if @exact_match_operator in query_operators or @all_operators in query_operators,
          do: params,
          else: Map.delete(params, param_key)
      end

      defp build_query_for_not_allowed_fields(query, not_allowed_params) do
        Enum.reduce(not_allowed_params, query, fn payload, query ->
          not_allowed_fields_filter_fallback(
            query,
            payload["field"],
            payload["operator"],
            payload["compare_with"]
          )
        end)
      end

      defp remove_fields_with_ignoreable_values(params) do
        Enum.reduce(params, params, fn {param_key, param_value}, params ->
          if param_key in Map.keys(@ignoreable_fields_values) do
            do_remove_fields_with_ignoreable_values(
              @ignoreable_fields_values[param_key],
              params,
              {param_key, param_value}
            )
          else
            params
          end
        end)
      end

      defp do_remove_fields_with_ignoreable_values(ignoreable_field_value, params, {param_key, param_value})
           when not is_list(ignoreable_field_value) or length(ignoreable_field_value) == 0 do
        do_remove_fields_with_ignoreable_values([ignoreable_field_value], params, {param_key, param_value})
      end

      defp do_remove_fields_with_ignoreable_values(ignoreable_field_values, params, {param_key, param_value})
           when is_map(param_value) do
        Enum.reduce(param_value, params, fn {operator, compare_with}, params ->
          if compare_with in ignoreable_field_values,
            do: params |> pop_in([param_key, operator]) |> elem(1),
            else: params
        end)
      end

      defp do_remove_fields_with_ignoreable_values(ignoreable_field_values, params, {param_key, compare_with}) do
        if compare_with in ignoreable_field_values,
          do: Map.delete(params, param_key),
          else: params
      end

      defoverridable not_allowed_fields_filter_fallback: 4
    end
  end
end
