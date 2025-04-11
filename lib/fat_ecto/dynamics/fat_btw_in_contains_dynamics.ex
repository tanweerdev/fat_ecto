defmodule FatEcto.Dynamics.FatBtwInContainsDynamics do
  @moduledoc """
  Provides dynamic query builders for common Ecto operations, such as filtering by ranges (`between`),
  membership (`in`), and JSONB containment (`contains`).

  This module is designed to simplify the creation of dynamic queries for Ecto schemas, particularly
  when dealing with complex filtering conditions.

  ## Example Usage

      iex> result = #{__MODULE__}.between_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)"
  """

  import Ecto.Query

  @doc """
  Builds a dynamic query where a field's value is between two provided values (exclusive).

  ### Parameters

    - `key`       - The field name as an atom.
    - `values`    - A list of two values representing the range.

  ### Examples

      iex> result = #{__MODULE__}.between_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)"
  """
  @spec between_dynamic(atom(), [any()]) :: Ecto.Query.dynamic_expr()
  def between_dynamic(key, [min, max] = values) when is_atom(key) and is_list(values) do
    dynamic(
      [q],
      field(q, ^key) > ^min and
        field(q, ^key) < ^max
    )
  end

  @doc """
  Builds a dynamic query where a field's value is between or equal to two provided values (inclusive).

  ### Parameters

    - `key`       - The field name as an atom.
    - `values`    - A list of two values representing the range.

  ### Examples

      iex> result = #{__MODULE__}.between_equal_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5)"
  """
  @spec between_equal_dynamic(atom(), [any()]) :: Ecto.Query.dynamic_expr()
  def between_equal_dynamic(key, [min, max] = values) when is_atom(key) and is_list(values) do
    dynamic(
      [q],
      field(q, ^key) >= ^min and
        field(q, ^key) <= ^max
    )
  end

  @doc """
  Builds a dynamic query where a field's value is in a provided list.

  ### Parameters

    - `key`       - The field name as an atom.
    - `values`    - A list of values to match against.

  ### Examples

      iex> result = #{__MODULE__}.in_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years in ^[2, 5])"
  """
  @spec in_dynamic(atom(), [any()]) :: Ecto.Query.dynamic_expr()
  def in_dynamic(key, values) when is_atom(key) and is_list(values) do
    dynamic(
      [q],
      field(q, ^key) in ^values
    )
  end

  @doc """
  Builds a dynamic query where a JSONB field contains a specific value.

  ### Parameters

    - `key`       - The JSONB field name as an atom.
    - `value`     - The value to check for containment.

  ### Examples

      iex> result = #{__MODULE__}.contains_dynamic(:metadata, %{"role" => "admin"})
      iex> inspect(result)
      "dynamic([q], fragment(\\\"? @> ?\\\", q.metadata, ^%{\\\"role\\\" => \\\"admin\\\"}))"
  """
  @spec contains_dynamic(atom(), map() | list()) :: Ecto.Query.dynamic_expr()
  def contains_dynamic(key, value) when is_atom(key) do
    dynamic(
      [q],
      fragment("? @> ?", field(q, ^key), ^value)
    )
  end

  @doc """
  Builds a dynamic query where a JSONB field contains any of the provided values.

  ### Parameters

    - `key`       - The JSONB field name as an atom.
    - `values`    - The values to check for overlap.

  ### Examples

      iex> result = #{__MODULE__}.contains_any_dynamic(:tags, ["elixir", "erlang"])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"? && ?\\\", q.tags, ^[\\\"elixir\\\", \\\"erlang\\\"]))"
  """
  @spec contains_any_dynamic(atom(), [any()]) :: Ecto.Query.dynamic_expr()
  def contains_any_dynamic(key, values) when is_atom(key) and is_list(values) do
    dynamic(
      [q],
      fragment("? && ?", field(q, ^key), ^values)
    )
  end

  @doc """
  Builds a dynamic query where a field's value is not between the provided range (exclusive).

  ### Parameters

    - `key`       - The field name as an atom.
    - `values`    - A list of two values representing the range.

  ### Examples

      iex> result = #{__MODULE__}.not_between_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years < ^2 or q.experience_years > ^5)"
  """
  @spec not_between_dynamic(atom(), [any()]) :: Ecto.Query.dynamic_expr()
  def not_between_dynamic(key, [min, max] = values) when is_atom(key) and is_list(values) do
    dynamic(
      [q],
      field(q, ^key) < ^min or
        field(q, ^key) > ^max
    )
  end

  @doc """
  Builds a dynamic query where a field's value is not between or equal to the provided range (inclusive).

  ### Parameters

    - `key`       - The field name as an atom.
    - `values`    - A list of two values representing the range.

  ### Examples

      iex> result = #{__MODULE__}.not_between_equal_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years <= ^2 or q.experience_years >= ^5)"
  """
  @spec not_between_equal_dynamic(atom(), [any()]) :: Ecto.Query.dynamic_expr()
  def not_between_equal_dynamic(key, [min, max] = values) when is_atom(key) and is_list(values) do
    dynamic(
      [q],
      field(q, ^key) <= ^min or
        field(q, ^key) >= ^max
    )
  end

  @doc """
  Builds a dynamic query where a field's value is not in the provided list.

  ### Parameters

    - `key`       - The field name as an atom.
    - `values`    - A list of values to exclude.

  ### Examples

      iex> result = #{__MODULE__}.not_in_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years not in ^[2, 5])"
  """
  @spec not_in_dynamic(atom(), [any()]) :: Ecto.Query.dynamic_expr()
  def not_in_dynamic(key, values) when is_atom(key) and is_list(values) do
    dynamic(
      [q],
      field(q, ^key) not in ^values
    )
  end

  @doc """
  Builds a dynamic query where a JSONB field does not contain a specific value.

  ### Parameters

    - `key`       - The JSONB field name as an atom.
    - `value`     - The value to check for absence.

  ### Examples

      iex> result = #{__MODULE__}.not_contains_dynamic(:metadata, %{"role" => "admin"})
      iex> inspect(result)
      "dynamic([q], not fragment(\\\"? @> ?\\\", q.metadata, ^%{\\\"role\\\" => \\\"admin\\\"}))"
  """
  @spec not_contains_dynamic(atom(), map() | list()) :: Ecto.Query.dynamic_expr()
  def not_contains_dynamic(key, value) when is_atom(key) do
    dynamic(
      [q],
      not fragment("? @> ?", field(q, ^key), ^value)
    )
  end

  @doc """
  Builds a dynamic query where a JSONB field does not contain any of the provided values.

  ### Parameters

    - `key`       - The JSONB field name as an atom.
    - `values`    - The values to check for absence.

  ### Examples

      iex> result = #{__MODULE__}.not_contains_any_dynamic(:tags, ["elixir", "erlang"])
      iex> inspect(result)
      "dynamic([q], not fragment(\\\"? && ?\\\", q.tags, ^[\\\"elixir\\\", \\\"erlang\\\"]))"
  """
  @spec not_contains_any_dynamic(atom(), [any()]) :: Ecto.Query.dynamic_expr()
  def not_contains_any_dynamic(key, values) when is_atom(key) and is_list(values) do
    dynamic(
      [q],
      not fragment("? && ?", field(q, ^key), ^values)
    )
  end
end
