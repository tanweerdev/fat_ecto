defmodule FatEcto.Query.Dynamics.GtLtEq do
  @moduledoc """
  Provides dynamic query builders for common Ecto operations, such as filtering by comparison operators
  (`>`, `<`, `>=`, `<=`, `==`, `!=`) and handling `nil` values.

  This module is designed to simplify the creation of dynamic queries for Ecto schemas, particularly
  when dealing with comparison-based filtering conditions.

  ## Named Bindings (Join Filters)

  All functions support an optional `binding` parameter for filtering on joined tables.
  When `nil` (default), uses the standard `[q]` binding.
  When an atom is provided, uses a named binding `[{binding, j}]`.

  ### Examples

      # Direct filter (no binding)
      eq_dynamic(:status, "active")
      # => dynamic([q], q.status == ^"active")

      # Join filter (with binding)
      eq_dynamic(:subject_id, "uuid", :classifications)
      # => dynamic([classifications: j], j.subject_id == ^"uuid")

  ## Example Usage

      iex> result = #{__MODULE__}.field_is_nil_dynamic(:location)
      iex> inspect(result)
      "dynamic([q], is_nil(q.location))"
  """

  import Ecto.Query

  @doc """
  Builds a dynamic query where a field is `nil`.

  ### Parameters

    - `key` - The field name as an atom.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.field_is_nil_dynamic(:location)
      iex> inspect(result)
      "dynamic([q], is_nil(q.location))"
  """
  @spec field_is_nil_dynamic(atom(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def field_is_nil_dynamic(key, binding \\ nil)

  def field_is_nil_dynamic(key, nil) when is_atom(key) do
    dynamic([q], is_nil(field(q, ^key)))
  end

  def field_is_nil_dynamic(key, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], is_nil(field(j, ^key)))
  end

  @doc """
  Builds a dynamic query where a field is greater than a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.gt_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years > ^2)"
  """
  @spec gt_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def gt_dynamic(key, value, binding \\ nil)

  def gt_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) > ^value)
  end

  def gt_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) > ^value)
  end

  @doc """
  Builds a dynamic query where a field is greater than or equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.gte_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years >= ^2)"
  """
  @spec gte_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def gte_dynamic(key, value, binding \\ nil)

  def gte_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) >= ^value)
  end

  def gte_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) >= ^value)
  end

  @doc """
  Builds a dynamic query where a field is less than or equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.lte_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years <= ^2)"
  """
  @spec lte_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def lte_dynamic(key, value, binding \\ nil)

  def lte_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) <= ^value)
  end

  def lte_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) <= ^value)
  end

  @doc """
  Builds a dynamic query where a field is less than a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.lt_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years < ^2)"
  """
  @spec lt_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def lt_dynamic(key, value, binding \\ nil)

  def lt_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) < ^value)
  end

  def lt_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) < ^value)
  end

  @doc """
  Builds a dynamic query where a field is equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.eq_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years == ^2)"
  """
  @spec eq_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def eq_dynamic(key, value, binding \\ nil)

  def eq_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) == ^value)
  end

  def eq_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) == ^value)
  end

  @doc """
  Builds a dynamic query where a field cast to `date` is equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against (must be a `Date`).
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_eq_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date) == ^~D[2025-02-08])"
  """
  @spec cast_to_date_eq_dynamic(atom(), Date.t(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def cast_to_date_eq_dynamic(key, value, binding \\ nil)

  def cast_to_date_eq_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], fragment("?::date", field(q, ^key)) == ^value)
  end

  def cast_to_date_eq_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], fragment("?::date", field(j, ^key)) == ^value)
  end

  @doc """
  Builds a dynamic query where a field cast to `date` is not equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against (must be a `Date`).
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_not_eq_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date) != ^~D[2025-02-08])"
  """
  @spec cast_to_date_not_eq_dynamic(atom(), Date.t(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def cast_to_date_not_eq_dynamic(key, value, binding \\ nil)

  def cast_to_date_not_eq_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], fragment("?::date", field(q, ^key)) != ^value)
  end

  def cast_to_date_not_eq_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], fragment("?::date", field(j, ^key)) != ^value)
  end

  @doc """
  Builds a dynamic query where a field cast to `date` is greater than a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against (must be a `Date`).
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_gt_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date) > ^~D[2025-02-08])"
  """
  @spec cast_to_date_gt_dynamic(atom(), Date.t(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def cast_to_date_gt_dynamic(key, value, binding \\ nil)

  def cast_to_date_gt_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], fragment("?::date", field(q, ^key)) > ^value)
  end

  def cast_to_date_gt_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], fragment("?::date", field(j, ^key)) > ^value)
  end

  @doc """
  Builds a dynamic query where a field cast to `date` is greater than or equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against (must be a `Date`).
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_gte_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date) >= ^~D[2025-02-08])"
  """
  @spec cast_to_date_gte_dynamic(atom(), Date.t(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def cast_to_date_gte_dynamic(key, value, binding \\ nil)

  def cast_to_date_gte_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], fragment("?::date", field(q, ^key)) >= ^value)
  end

  def cast_to_date_gte_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], fragment("?::date", field(j, ^key)) >= ^value)
  end

  @doc """
  Builds a dynamic query where a field cast to `date` is less than a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against (must be a `Date`).
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_lt_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date) < ^~D[2025-02-08])"
  """
  @spec cast_to_date_lt_dynamic(atom(), Date.t(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def cast_to_date_lt_dynamic(key, value, binding \\ nil)

  def cast_to_date_lt_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], fragment("?::date", field(q, ^key)) < ^value)
  end

  def cast_to_date_lt_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], fragment("?::date", field(j, ^key)) < ^value)
  end

  @doc """
  Builds a dynamic query where a field cast to `date` is less than or equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against (must be a `Date`).
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_lte_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date) <= ^~D[2025-02-08])"
  """
  @spec cast_to_date_lte_dynamic(atom(), Date.t(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def cast_to_date_lte_dynamic(key, value, binding \\ nil)

  def cast_to_date_lte_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], fragment("?::date", field(q, ^key)) <= ^value)
  end

  def cast_to_date_lte_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], fragment("?::date", field(j, ^key)) <= ^value)
  end

  @doc """
  Builds a dynamic query where a field is not `nil`.

  ### Parameters

    - `key` - The field name as an atom.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.not_field_is_nil_dynamic(:location)
      iex> inspect(result)
      "dynamic([q], not is_nil(q.location))"
  """
  @spec not_field_is_nil_dynamic(atom(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def not_field_is_nil_dynamic(key, binding \\ nil)

  def not_field_is_nil_dynamic(key, nil) when is_atom(key) do
    dynamic([q], not is_nil(field(q, ^key)))
  end

  def not_field_is_nil_dynamic(key, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], not is_nil(field(j, ^key)))
  end

  @doc """
  Builds a dynamic query where a field is not greater than a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.not_gt_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years <= ^2)"
  """
  @spec not_gt_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def not_gt_dynamic(key, value, binding \\ nil)

  def not_gt_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) <= ^value)
  end

  def not_gt_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) <= ^value)
  end

  @doc """
  Builds a dynamic query where a field is not greater than or equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.not_gte_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years < ^2)"
  """
  @spec not_gte_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def not_gte_dynamic(key, value, binding \\ nil)

  def not_gte_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) < ^value)
  end

  def not_gte_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) < ^value)
  end

  @doc """
  Builds a dynamic query where a field is not less than or equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.not_lte_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years > ^2)"
  """
  @spec not_lte_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def not_lte_dynamic(key, value, binding \\ nil)

  def not_lte_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) > ^value)
  end

  def not_lte_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) > ^value)
  end

  @doc """
  Builds a dynamic query where a field is not less than a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.not_lt_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years >= ^2)"
  """
  @spec not_lt_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def not_lt_dynamic(key, value, binding \\ nil)

  def not_lt_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) >= ^value)
  end

  def not_lt_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) >= ^value)
  end

  @doc """
  Builds a dynamic query where a field is not equal to a given value.

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The value to compare against.
    - `binding` - Optional named binding atom for join filters (default: nil).

  ### Examples

      iex> result = #{__MODULE__}.not_eq_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years != ^2)"
  """
  @spec not_eq_dynamic(atom(), any(), atom() | nil) :: Ecto.Query.dynamic_expr()
  def not_eq_dynamic(key, value, binding \\ nil)

  def not_eq_dynamic(key, value, nil) when is_atom(key) do
    dynamic([q], field(q, ^key) != ^value)
  end

  def not_eq_dynamic(key, value, binding) when is_atom(key) and is_atom(binding) do
    dynamic([{^binding, j}], field(j, ^key) != ^value)
  end
end
