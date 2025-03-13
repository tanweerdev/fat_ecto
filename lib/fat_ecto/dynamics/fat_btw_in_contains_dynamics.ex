defmodule FatEcto.Dynamics.FatBtwInContainsDynamics do
  import Ecto.Query

  @doc """
  Builds a dynamic query where a field's value is between two provided values.

  ### Parameters

    - `key`       - The field name.
    - `values`    - A list of two values representing the range.

  ### Examples

      iex> result = #{__MODULE__}.between_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)"
  """
  @spec between_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def between_dynamic(key, values) do
    dynamic(
      [q],
      field(q, ^key) > ^Enum.min(values) and
        field(q, ^key) < ^Enum.max(values)
    )
  end

  @doc """
  Builds a dynamic query where a field's value is between or equal to two provided values.

  ### Parameters

    - `key`       - The field name.
    - `values`    - A list of two values representing the range.

  ### Examples

      iex> result = #{__MODULE__}.between_equal_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5)"
  """
  @spec between_equal_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def between_equal_dynamic(key, values) do
    dynamic(
      [q],
      field(q, ^key) >= ^Enum.min(values) and
        field(q, ^key) <= ^Enum.max(values)
    )
  end

  @doc """
  Builds a dynamic query where a field's value is in a provided list.

  ### Parameters

    - `key`       - The field name.
    - `values`    - A list of values to match against.

  ### Examples

      iex> result = #{__MODULE__}.in_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years in ^[2, 5])"
  """
  @spec in_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def in_dynamic(key, values) do
    dynamic(
      [q],
      field(q, ^key) in ^values
    )
  end

  @doc """
  Builds a dynamic query where a JSONB field contains a specific value.

  ### Parameters

    - `key`       - The JSONB field name.
    - `values`    - The value(s) to check for containment.

  ### Examples

      iex> result = #{__MODULE__}.contains_dynamic(:metadata, %{"role" => "admin"})
      iex> inspect(result)
      "dynamic([q], fragment(\\\"? @> ?\\\", q.metadata, ^%{\\\"role\\\" => \\\"admin\\\"}))"
  """
  @spec contains_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def contains_dynamic(key, values) do
    dynamic(
      [q],
      fragment("? @> ?", field(q, ^key), ^values)
    )
  end

  @doc """
  Builds a dynamic query where a JSONB field contains any of the provided values.

  ### Parameters

    - `key`       - The JSONB field name.
    - `values`    - The values to check for overlap.

  ### Examples

      iex> result = #{__MODULE__}.contains_any_dynamic(:tags, ["elixir", "erlang"])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"? && ?\\\", q.tags, ^[\\\"elixir\\\", \\\"erlang\\\"]))"
  """
  @spec contains_any_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def contains_any_dynamic(key, values) do
    dynamic(
      [q],
      fragment("? && ?", field(q, ^key), ^values)
    )
  end

  @doc """
  Builds a dynamic query where value is not between the provided attributes.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Values of the field as a list.

  ### Examples

      iex> result = #{__MODULE__}.not_between_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years < ^2 or q.experience_years > ^5)"
  """

  @spec not_between_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_between_dynamic(key, values) do
    dynamic(
      [q],
      field(q, ^key) < ^Enum.min(values) or
        field(q, ^key) > ^Enum.max(values)
    )
  end

  @doc """
  Builds a dynamic query where value is not equal and between the provided attributes.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Values of the field as a list.

  ### Examples

      iex> result = #{__MODULE__}.not_between_equal_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years <= ^2 or q.experience_years >= ^5)"

  """

  @spec not_between_equal_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_between_equal_dynamic(key, values) do
    dynamic(
      [q],
      field(q, ^key) <= ^Enum.min(values) or
        field(q, ^key) >= ^Enum.max(values)
    )
  end

  @doc """
  Builds a dynamic query where value is not in the the list attributes.
  ### Parameters

     - `key`       - Field name.
     - `values`    - Pass a list of values of the field that represent range.


  ### Examples

      iex> result = #{__MODULE__}.not_in_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years not in ^[2, 5])"

  """

  @spec not_in_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_in_dynamic(key, values) do
    dynamic(
      [q],
      field(q, ^key) not in ^values
    )
  end

  @doc """
  Builds a dynamic query when value of jsonb field is not in the list.
  ### Parameters

     - `key`       - Field name.
     - `values`    - values of jsonb field.
  """

  @spec not_contains_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_contains_dynamic(key, values) do
    # value = Enum.join(value, " ")
    # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

    dynamic(
      [q],
      not fragment("? @> ?", field(q, ^key), ^values)
    )
  end

  @doc """
  Builds a dynamic query when value of jsonb not matches with any list attribute.
  ### Parameters

     - `key`       - Field name.
     - `values`    - values of jsonb field.
  """

  @spec not_contains_any_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_contains_any_dynamic(key, values) do
    dynamic(
      [q],
      not fragment("? && ?", field(q, ^key), ^values)
    )
  end
end
