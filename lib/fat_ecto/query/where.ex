defmodule FatEcto.FatQuery.FatWhere do
  @moduledoc """
  Provides functionality to build `where` clauses for Ecto queries based on various conditions.

  This module supports a wide range of query conditions such as `like`, `ilike`, `not_like`, `not_ilike`,
  `lt`, `lte`, `gt`, `gte`, `between`, `not_between`, `in`, `not_in`, `is_nil`, `not_null`, `$or`, and `$not`.

  ## Usage

  The `build_where/4` function is the main entry point, which takes a queryable, a map of where conditions,
  and additional options to build the `where` clause dynamically.

  ### Example

      iex> where_params = %{"location" => %{"$like" => "%street%"}}
      iex> FatEcto.FatQuery.FatWhere.build_where(FatEcto.FatHospital, where_params, %{})
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: like(fragment("(?)::TEXT", f0.location), ^"%street%") and ^true>

  ## Supported Conditions

  ### Basic Comparisons
  - `$like`: Matches a pattern in a string.
  - `$ilike`: Case-insensitive match of a pattern in a string.
  - `$not_like`: Excludes rows that match a pattern in a string.
  - `$not_ilike`: Case-insensitive exclusion of rows that match a pattern in a string.
  - `$lt`: Less than.
  - `$lte`: Less than or equal to.
  - `$gt`: Greater than.
  - `$gte`: Greater than or equal to.
  - `$equal`: Equal to a value.
  - `$not_equal`: Not equal to a value.

  ### Range Conditions
  - `$between`: Matches values between a range (exclusive).
  - `$not_between`: Excludes values between a range (exclusive).
  - `$in`: Matches values in a list.
  - `$not_in`: Excludes values in a list.

  ### Null Checks
  - `$is_nil`: Matches rows where the field is `nil`.
  - `$not_null`: Matches rows where the field is not `nil`.

  ### Logical Conditions
  - `$or`: Combines multiple conditions with a logical OR.
  - `$not`: Negates a condition.

  ## Examples

  ### Like Condition
      iex> where_params = %{"name" => %{"$like" => "%John%"}}
      iex> FatEcto.FatQuery.FatWhere.build_where(FatEcto.FatDoctor, where_params, %{})
      #Ecto.Query<from f0 in FatEcto.FatDoctor, where: like(fragment("(?)::TEXT", f0.name), ^"%John%") and ^true>

  ### Greater Than Condition
      iex> where_params = %{"rating" => %{"$gt" => 4}}
      iex> FatEcto.FatQuery.FatWhere.build_where(FatEcto.FatHospital, where_params, %{})
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating > ^4 and ^true>

  ### Between Condition
      iex> where_params = %{"rating" => %{"$between" => [3, 5]}}
      iex> FatEcto.FatQuery.FatWhere.build_where(FatEcto.FatHospital, where_params, %{})
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating > ^3 and f0.rating < ^5 and ^true>

  ### OR Condition
      iex> where_params = %{"$or" => %{"rating" => %{"$gt" => 4}, "name" => %{"$like" => "%John%"}}}
      iex> FatEcto.FatQuery.FatWhere.build_where(FatEcto.FatDoctor, where_params, %{})
      #Ecto.Query<from f0 in FatEcto.FatDoctor, where: (f0.rating > ^4 or like(fragment("(?)::TEXT", f0.name), ^"%John%")) and ^true>

  ### NOT Condition
      iex> where_params = %{"rating" => %{"$not" => %{"$gt" => 4}}}
      iex> FatEcto.FatQuery.FatWhere.build_where(FatEcto.FatHospital, where_params, %{})
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: not(f0.rating > ^4) and ^true>
  """

  import Ecto.Query
  alias FatEcto.FatHelper
  alias FatEcto.FatQuery.{FatDynamics, FatNotDynamics, WhereOr}
  alias FatEcto.FatQuery.OperatorHelper

  @doc """
  Builds a `where` clause for an Ecto query based on the provided conditions.

  ### Parameters

  - `queryable`: The Ecto queryable (schema, table, or query).
  - `where_params`: A map of where conditions.
  - `build_options`: Additional options for building the query.
  - `opts`: Additional options for the where clause.

  ### Returns

  An `Ecto.Query` with the applied where conditions.
  """
  @spec build_where(Ecto.Queryable.t(), map() | keyword(), keyword()) :: Ecto.Query.t()
  def build_where(queryable, where_params, opts \\ [])

  def build_where(queryable, nil, _opts) do
    queryable
  end

  def build_where(queryable, where_params, opts) do
    queryable = {%{}, queryable}

    {where_params, queryable} =
      Enum.reduce(where_params, queryable, fn {k, v}, {map, queryable} ->
        if String.contains?(k, "$or") do
          {map, WhereOr.or_condition(queryable, where_params[k], opts)}
        else
          {Map.put(map, k, v), queryable}
        end
      end)

    dynamics =
      Enum.reduce(where_params, true, fn {k, v}, dynamics ->
        query_where(dynamics, {k, v}, opts)
      end)

    from(q in queryable, where: ^dynamics)
  end

  defp query_where(dynamics, {k, map_cond}, opts) when is_map(map_cond) do
    case k do
      "$or" ->
        Enum.reduce(map_cond, dynamics, fn {key, condition}, dynamics ->
          field = FatHelper.string_to_existing_atom(key)
          apply_condition(dynamics, field, condition, opts)
        end)

      "$not" ->
        Enum.reduce(map_cond, dynamics, fn {key, condition}, dynamics ->
          field = FatHelper.string_to_existing_atom(key)
          apply_not_condition(dynamics, field, condition, opts)
        end)

      _ ->
        Enum.reduce(map_cond, dynamics, fn {key, value}, dynamics ->
          field = FatHelper.string_to_existing_atom(k)
          apply_condition(dynamics, field, %{key => value}, opts)
        end)
    end
  end

  defp query_where(dynamics, {k, nil}, opts) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics and FatDynamics.nil_dynamic?(field, opts)
  end

  defp query_where(dynamics, {k, "$not_null"}, opts) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics and FatNotDynamics.not_nil_dynamic?(field, opts)
  end

  defp query_where(dynamics, {k, map_cond}, opts) when not is_list(map_cond) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics and FatDynamics.eq_dynamic(field, map_cond, opts)
  end

  defp query_where(dynamics, {k, map_cond}, opts) when is_list(map_cond) and k == "$not_null" do
    Enum.reduce(map_cond, dynamics, fn key, dynamics ->
      field = FatHelper.string_to_existing_atom(key)
      dynamics and FatNotDynamics.not_nil_dynamic?(field, opts)
    end)
  end

  defp query_where(dynamics, {k, map_cond}, opts) when is_list(map_cond) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics and FatDynamics.eq_dynamic(field, map_cond, opts)
  end

  defp apply_condition(dynamics, field, condition, opts) do
    Enum.reduce(condition, dynamics, fn {operator, value}, dynamics ->
      if operator in OperatorHelper.allowed_operators() do
        dynamics and OperatorHelper.apply_operator(operator, field, value, opts)
      else
        dynamics
      end
    end)
  end

  defp apply_not_condition(dynamics, field, condition, opts) do
    Enum.reduce(condition, dynamics, fn {operator, value}, dynamics ->
      if operator in OperatorHelper.allowed_not_operators() do
        dynamics and OperatorHelper.apply_not_condition(operator, field, value, opts)
      else
        dynamics
      end
    end)
  end
end
