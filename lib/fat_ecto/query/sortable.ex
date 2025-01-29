# defmodule FatEcto.FatQuery.Sortable do
#   @moduledoc """
#     Build query after sorting on basis of user provided allowed & customizable fields from given parameters.
#   """

#   alias FatEcto.FatQuery.FatOrderBy

#   @doc """
#    This function act as fallback for the customizable_fields default behaviour is to return query but is overridable
#   """
#   @callback custom_orderby_fallback(
#               query :: Ecto.Query.t(),
#               customizable_field :: String.t() | atom(),
#               operator :: String.t()
#             ) ::
#               Ecto.Query.t()

#   defmacro(__using__(options \\ [])) do
#     quote do
#       @behaviour FatEcto.FatQuery.Sortable
#       @options unquote(options)
#       @allowed_fields @options[:allowed_fields] || %{}
#       @customizable_fields @options[:customizable_fields] || %{}
#       @all_operators "*"

#       def build(queryable, order_by_params, build_options \\ []) do
#         {customizable_params, filtered_allowed_params} =
#           order_by_params
#           |> orderby_allowed_fields(@allowed_fields)
#           |> orderby_customizable_fields(order_by_params, @customizable_fields)

#         queryable
#         |> FatOrderBy.build_order_by(filtered_allowed_params, build_options)
#         |> build_query_for_customizable_fields(customizable_params)
#       end

#       def custom_orderby_fallback(query, _field, _operator), do: query

#       defp orderby_allowed_fields(params, allowed_fields) when allowed_fields == %{}, do: params

#       defp orderby_allowed_fields(params, allowed_fields) do
#         Enum.reduce(params, params, fn {k, v} = key_value, params ->
#           if operator = allowed_fields[k],
#             do: orderby_query_expressions(operator, key_value, params, :allowed_fields),
#             else: Map.delete(params, k)
#         end)
#       end

#       defp orderby_customizable_fields(filtered_params, _params, customizable_fields)
#            when customizable_fields == %{},
#            do: {[], filtered_params}

#       defp orderby_customizable_fields(filtered_params, params, customizable_fields) do
#         {customizable_fields, params} =
#           Enum.reduce(params, {[], params}, fn {k, v} = key_value, {customizable_params, params} = acc ->
#             if operator = customizable_fields[k],
#               do: orderby_query_expressions(operator, key_value, acc, :customizable_fields),
#               else: acc
#           end)

#         if @allowed_fields != %{},
#           do: {customizable_fields, filtered_params},
#           else: {customizable_fields, params}
#       end

#       defp orderby_query_expressions(operator, {k, v}, params, :allowed_fields)
#            when is_binary(operator) do
#         if operator in [v, @all_operators],
#           do: params,
#           else: params |> pop_in([k]) |> elem(1)
#       end

#       defp orderby_query_expressions(operator, {k, v}, {customizable_params, params}, :customizable_fields)
#            when is_binary(operator) do
#         if operator in [v, @all_operators] do
#           customizable_params = [%{"field" => k, "operator" => v} | customizable_params]
#           params = params |> pop_in([k]) |> elem(1)
#           {customizable_params, params}
#         else
#           {customizable_params, params}
#         end
#       end

#       defp build_query_for_customizable_fields(query, customizable_params) do
#         Enum.reduce(customizable_params, query, fn payload, query ->
#           custom_orderby_fallback(
#             query,
#             payload["field"],
#             payload["operator"]
#           )
#         end)
#       end

#       defoverridable custom_orderby_fallback: 3
#     end
#   end
# end
