defmodule FatEcto.Dynamics.FatGtLtEqDynamics do
  @moduledoc """
  Provides functions to build dynamic `where` conditions for Ecto queries.

  This module is designed to construct complex `where` clauses dynamically using Ecto's `dynamic/2` macro.
  It supports a variety of conditions such as equality, inequality, comparison operators (`>`, `<`, `>=`, `<=`),
  `IN` clauses, `LIKE`/`ILIKE` for string matching, and JSONB operations (`@>`, `&&`).

  ### Key Features:
  - **Dynamic Conditions**: Builds `where` clauses dynamically based on field names, values, and logic types (`:and`/`:or`).
  - **Binding Support**: Supports query bindings for joins or nested queries via the `:binding` option.
  - **JSONB Operations**: Provides functions to work with JSONB fields, such as checking containment or overlap.
  - **String Matching**: Supports `LIKE` and `ILIKE` for substring matching, including case-insensitive searches.
  - **Range Queries**: Allows building conditions for ranges (`BETWEEN`, `IN`, etc.).

  ### Usage:
  Each function in this module constructs a dynamic expression that can be combined with other dynamics or used directly
  in an Ecto query. The functions accept the following common parameters:
  - `key`: The field name (as a string or atom).
  - `value`: The value to compare against (can be a single value, list, or map depending on the function).
  - `opts`: Options to control the behavior, such `:binding` (`:last` for joins).

  ### Example:
    iex> result = #{__MODULE__}.field_is_nil_dynamic(:location)
    iex> inspect(result)
    "dynamic([c], is_nil(c.location))"

  This module is typically used internally by `FatEcto` to construct queries based on user-provided filters.
  """
  import Ecto.Query

  @doc """
  Builds a dynamic query where field is nil.

  Parameters
  - `key`       - Field name.
  Examples
    iex> result = #{__MODULE__}.field_is_nil_dynamic(:location)
    iex> inspect(result)
    "dynamic([c], is_nil(c.location))"
  """
  @spec field_is_nil_dynamic(any()) :: Ecto.Query.dynamic_expr()
  def field_is_nil_dynamic(key) do
    dynamic(
      [c],
      is_nil(field(c, ^key))
    )
  end

  @doc """
  Builds dynamic condition for field greater than value.

  Parameters
   - `key`       - Field name.
   - `value`     - Comparison value or field reference.
  Examples
    iex> result = #{__MODULE__}.gt_dynamic(:experience_years, 2)
    iex> inspect(result)
    "dynamic([c], c.experience_years > ^2)"
  """
  @spec gt_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def gt_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) > ^value
    )
  end

  @doc """
  Builds dynamic condition for field greater than or equal to value.

  Parameters
   - `key`       - Field name.
   - `value`     - Comparison value or field reference.
  Examples
    iex> result = #{__MODULE__}.gte_dynamic(:experience_years, 2)
    iex> inspect(result)
    "dynamic([c], c.experience_years >= ^2)"
  """
  @spec gte_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def gte_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) >= ^value
    )
  end

  @doc """
  Builds dynamic condition for field less than or equal to value.

  Parameters
   - `key`       - Field name.
   - `value`     - Comparison value or field reference.
  Examples
    iex> result = #{__MODULE__}.lte_dynamic(:experience_years, 2)
    iex> inspect(result)
    "dynamic([q], q.experience_years <= ^2)"
  """
  @spec lte_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def lte_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) <= ^value
    )
  end

  @doc """
  Builds a dynamic query where a field is less than a given value.

  ### Parameters

    - `key`       - The field name.
    - `value`     - The value to compare against.

  ### Examples

      iex> result = #{__MODULE__}.lt_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([c], c.experience_years < ^2)"
  """
  @spec lt_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def lt_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) < ^value
    )
  end

  @doc """
  Builds a dynamic query where field is equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.

  ### Examples

       iex> result = #{__MODULE__}.eq_dynamic(:experience_years, 2)
       iex> inspect(result)
       "dynamic([q], q.experience_years == ^2)"
  """

  @spec eq_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def eq_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) == ^value
    )
  end

  @doc """
  Builds a dynamic query where a field casted to date is equal to a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_eq_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date == ^~D[2025-02-08]))"
  """
  @spec cast_to_date_eq_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def cast_to_date_eq_dynamic(key, value) do
    dynamic(
      [q],
      fragment("?::date", field(q, ^key) == ^value)
    )
  end

  @doc """
  Builds a dynamic query where a field casted to date is greater than a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_gt_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date > ^~D[2025-02-08]))"
  """
  @spec cast_to_date_gt_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def cast_to_date_gt_dynamic(key, value) do
    dynamic(
      [q],
      fragment("?::date", field(q, ^key) > ^value)
    )
  end

  @doc """
  Builds a dynamic query where a field casted to date is great than or equal to a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_gte_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date >= ^~D[2025-02-08]))"
  """
  @spec cast_to_date_gte_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def cast_to_date_gte_dynamic(key, value) do
    dynamic(
      [q],
      fragment("?::date", field(q, ^key) >= ^value)
    )
  end

  @doc """
  Builds a dynamic query where a field casted to date is less than a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_lt_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date < ^~D[2025-02-08]))"
  """
  @spec cast_to_date_lt_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def cast_to_date_lt_dynamic(key, value) do
    dynamic(
      [q],
      fragment("?::date", field(q, ^key) < ^value)
    )
  end

  @doc """
  Builds a dynamic query where a field casted to date is less than or equal to a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_lte_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date <= ^~D[2025-02-08]))"
  """
  @spec cast_to_date_lte_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def cast_to_date_lte_dynamic(key, value) do
    dynamic(
      [q],
      fragment("?::date", field(q, ^key) <= ^value)
    )
  end

  @doc """
   Builds a dynamic query where field is not nil.
  ### Parameters

    - `key`       - Field name .

  ### Examples
      iex> result = #{__MODULE__}.not_field_is_nil_dynamic(:location)
      iex> inspect(result)
      "dynamic([c], not is_nil(c.location))"
  """
  @spec not_field_is_nil_dynamic(any()) :: Ecto.Query.dynamic_expr()
  def not_field_is_nil_dynamic(key) do
    dynamic(
      [c],
      not is_nil(field(c, ^key))
    )
  end

  @doc """
  Builds a dynamic query where field is not greater than the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.

  ### Examples

      iex> result = #{__MODULE__}.not_gt_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([c], c.experience_years < ^2)"
  """

  @spec not_gt_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_gt_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) < ^value
    )
  end

  @doc """
  Builds a dynamic query where field is not greater than or equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.

  ### Examples

      iex> result = #{__MODULE__}.not_gte_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([c], c.experience_years < ^2)"
  """

  @spec not_gte_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_gte_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) < ^value
    )
  end

  @doc """
  Builds a dynamic query where field is not less than or equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.

  ### Examples

      iex> result = #{__MODULE__}.not_lte_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([c], c.experience_years > ^2)"
  """

  @spec not_lte_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_lte_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) > ^value
    )
  end

  @doc """
  Builds a dynamic query where field is not less than the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.

  ### Examples

      iex> result = #{__MODULE__}.not_lt_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([c], c.experience_years > ^2)"
  """

  @spec not_lt_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_lt_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) > ^value
    )
  end

  @doc """
  Builds a dynamic query where field is not equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.

  ### Examples

       iex> result = #{__MODULE__}.not_eq_dynamic(:experience_years, 2)
       iex> inspect(result)
       "dynamic([q], q.experience_years != ^2)"
  """

  @spec not_eq_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_eq_dynamic(key, value) do
    dynamic(
      [q],
      field(q, ^key) != ^value
    )
  end
end
