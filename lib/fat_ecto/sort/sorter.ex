defmodule FatEcto.Sort.Sorter do
  @moduledoc """
  Builds order_by expressions in the format Ecto expects.
  """
  import Ecto.Query

  @type order_expr ::
          {:asc | :desc | :asc_nulls_first | :asc_nulls_last | :desc_nulls_first | :desc_nulls_last,
           Ecto.Query.dynamic_expr()}

  @doc """
  Builds order expressions from parameters.
  """
  @spec build_order_by(map(), map(), map()) :: [order_expr()]
  def build_order_by(order_by_params, field_aliases \\ %{}, join_filters_map \\ %{})

  def build_order_by(nil, _field_aliases, _join_filters_map), do: []
  def build_order_by(%{} = params, _field_aliases, _join_filters_map) when map_size(params) == 0, do: []

  def build_order_by(order_by_params, field_aliases, join_filters_map) do
    order_by_params
    |> Enum.reduce([], fn {field, operator}, acc ->
      resolved_field = resolve_sort_field(field, field_aliases)
      binding = get_join_binding(field, join_filters_map)

      case apply_order(resolved_field, operator, binding) do
        nil -> acc
        order_expr -> [order_expr | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp resolve_sort_field(field, nil), do: field
  defp resolve_sort_field(field, aliases) when aliases == %{}, do: field

  defp resolve_sort_field(field, aliases) do
    case Map.get(aliases, field) do
      nil -> field
      atom_field when is_atom(atom_field) -> Atom.to_string(atom_field)
      other -> other
    end
  end

  defp get_join_binding(_field, nil), do: nil
  defp get_join_binding(_field, join_filters) when join_filters == %{}, do: nil
  defp get_join_binding(field, join_filters), do: Map.get(join_filters, field)

  defp apply_order(field, operator, nil) when is_binary(field) do
    field_atom = String.to_existing_atom(field)

    case operator do
      "$DESC" -> {:desc, dynamic([q], field(q, ^field_atom))}
      "$ASC" -> {:asc, dynamic([q], field(q, ^field_atom))}
      "$ASC_NULLS_FIRST" -> {:asc_nulls_first, dynamic([q], field(q, ^field_atom))}
      "$ASC_NULLS_LAST" -> {:asc_nulls_last, dynamic([q], field(q, ^field_atom))}
      "$DESC_NULLS_FIRST" -> {:desc_nulls_first, dynamic([q], field(q, ^field_atom))}
      "$DESC_NULLS_LAST" -> {:desc_nulls_last, dynamic([q], field(q, ^field_atom))}
      _ -> nil
    end
  end

  defp apply_order(field, operator, binding) when is_binary(field) and is_atom(binding) do
    field_atom = String.to_existing_atom(field)

    case operator do
      "$DESC" -> {:desc, dynamic([{^binding, j}], field(j, ^field_atom))}
      "$ASC" -> {:asc, dynamic([{^binding, j}], field(j, ^field_atom))}
      "$ASC_NULLS_FIRST" -> {:asc_nulls_first, dynamic([{^binding, j}], field(j, ^field_atom))}
      "$ASC_NULLS_LAST" -> {:asc_nulls_last, dynamic([{^binding, j}], field(j, ^field_atom))}
      "$DESC_NULLS_FIRST" -> {:desc_nulls_first, dynamic([{^binding, j}], field(j, ^field_atom))}
      "$DESC_NULLS_LAST" -> {:desc_nulls_last, dynamic([{^binding, j}], field(j, ^field_atom))}
      _ -> nil
    end
  end
end
