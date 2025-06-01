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
  @spec build_order_by(map()) :: [order_expr()]
  def build_order_by(order_by_params)

  def build_order_by(nil), do: []
  def build_order_by(%{} = params) when map_size(params) == 0, do: []

  def build_order_by(order_by_params) do
    Enum.reduce(order_by_params, [], fn {field, operator}, acc ->
      case apply_order(field, operator) do
        nil -> acc
        order_expr -> [order_expr | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp apply_order(field, operator) when is_binary(field) do
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
end
