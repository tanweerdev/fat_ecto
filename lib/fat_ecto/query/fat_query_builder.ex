defmodule FatEcto.Query.FatQueryBuilder do
  @moduledoc """
  This module builds Ecto queries from a JSON-like structure.
  It uses the `FatEcto.Builder.FatOperatorHelper` module to apply operators and construct the query.
  """

  import Ecto.Query
  alias FatEcto.Builder.FatOperatorHelper

  @doc """
  Builds an Ecto query from a JSON-like structure.

  ## Examples

      iex> import Ecto.Query
      ...> query = FatEcto.Query.FatQueryBuilder.build(User, %{
      ...>   "$OR" => [
      ...>     %{"name" => "John"},
      ...>     %{"phone" => nil},
      ...>     %{"age" => %{"$GT" => 30}}
      ...>   ]
      ...> })
      iex> inspect(query)
      "#Ecto.Query<from u in User, where: u.age > ^30 or (is_nil(u.phone) or u.name == ^\"John\">"
  """
  @spec build(Ecto.Queryable.t(), map(), keyword()) :: Ecto.Query.t()
  def build(queryable, query_map, opts \\ []) do
    query = from(q in queryable)
    build_query(query, query_map, opts)
  end

  @spec build_query(Ecto.Query.t(), map(), keyword()) :: Ecto.Query.t()
  defp build_query(query, query_map, opts) when is_map(query_map) do
    Enum.reduce(query_map, query, fn {key, value}, acc ->
      case key do
        "$OR" ->
          build_or_query(acc, value, opts)

        "$AND" ->
          build_and_query(acc, value, opts)

        _ ->
          build_field_query(acc, key, value)
      end
    end)
  end

  # Handles "$OR" conditions
  defp build_or_query(query, conditions, opts) do
    or_dynamic =
      Enum.reduce(conditions, nil, fn condition, acc ->
        case acc do
          nil -> build_query(query, condition, opts)
          _ -> dynamic([q], ^build_query(query, condition, opts) or ^acc)
        end
      end)

    case or_dynamic do
      nil -> query
      _ -> where(query, ^or_dynamic)
    end
  end

  # Handles "$AND" conditions
  defp build_and_query(query, conditions, opts) do
    and_dynamic =
      Enum.reduce(conditions, nil, fn condition, acc ->
        case acc do
          nil -> build_query(query, condition, opts)
          _ -> dynamic([q], ^build_query(query, condition, opts) and ^acc)
        end
      end)

    case and_dynamic do
      nil -> query
      _ -> where(query, ^and_dynamic)
    end
  end

  # Handles individual field conditions
  defp build_field_query(query, field, conditions) when is_map(conditions) do
    field_dynamic =
      Enum.reduce(conditions, nil, fn {operator, value}, acc ->
        case FatOperatorHelper.apply_operator(operator, field, value) do
          nil ->
            acc

          operator_dynamic ->
            case acc do
              nil -> operator_dynamic
              _ -> dynamic([q], ^acc and ^operator_dynamic)
            end
        end
      end)

    case field_dynamic do
      nil -> query
      _ -> where(query, ^field_dynamic)
    end
  end

  # Handles direct field comparisons (e.g., "field" => "value" or "field" => nil)
  defp build_field_query(query, field, value) do
    field_dynamic =
      case value do
        nil -> FatOperatorHelper.apply_nil_operator("$NULL", field)
        _ -> FatOperatorHelper.apply_operator("$EQUAL", field, value)
      end

    case field_dynamic do
      nil -> query
      _ -> where(query, ^field_dynamic)
    end
  end
end
