defmodule FatEcto.FatQuery.FatNotDynamics do
  @moduledoc """
  Builds a `where query` using dynamics and not condition.

  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Where query options as a map.

  ### Examples

    iex> result = #{__MODULE__}.not_nil_dynamic?("location")
    iex> inspect(result)
    "dynamic([c], not is_nil(c.location))"

  ### Options

    - `$select` - Select the fields from `hospital` and `rooms`.
    - `$where`  - Added the where attribute in the query.
  """

  import Ecto.Query
  alias FatEcto.FatHelper

  @doc """
   Builds a dynamic query where field is not nil.
  ### Parameters

    - `key`       - Field name .
    - `opts`      - Options related to query bindings

  ### Examples
      iex> result = #{__MODULE__}.not_nil_dynamic?("location")
      iex> inspect(result)
      "dynamic([c], not is_nil(c.location))"
  """
  @spec not_nil_dynamic?(any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_nil_dynamic?(key, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        not is_nil(field(c, ^key))
      )
    else
      dynamic(
        [c],
        not is_nil(field(c, ^key))
      )
    end
  end

  @doc """
  Builds a dynamic query where field is not greater than the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `opts`      - Options related to query bindings

  ### Examples

      iex> result = #{__MODULE__}.not_gt_dynamic("experience_years", 2, [binding: :last])
      iex> inspect(result)
      "dynamic([_, ..., c], c.experience_years < ^2)"
  """

  @spec not_gt_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_gt_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [_, ..., c],
          field(c, ^key) < ^value
        )
      else
        dynamic(
          [_, ..., c],
          field(c, ^key) < ^value
        )
      end
    else
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [q],
          field(q, ^key) < ^value
        )
      else
        dynamic(
          [q],
          field(q, ^key) < ^value
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not greater than or equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `opts`      - Options related to query bindings

  ### Examples

      iex> result = #{__MODULE__}.not_gte_dynamic("experience_years", 2, [binding: :last])
      iex> inspect(result)
      "dynamic([_, ..., c], c.experience_years < ^2)"
  """

  @spec not_gte_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_gte_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [_, ..., c],
          field(c, ^key) < ^value
        )
      else
        dynamic(
          [_, ..., c],
          field(c, ^key) < ^value
        )
      end
    else
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [q],
          field(q, ^key) < ^value
        )
      else
        dynamic(
          [q],
          field(q, ^key) < ^value
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not less than or equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `opts`      - Options related to query bindings

  ### Examples

      iex> result = #{__MODULE__}.not_lte_dynamic("experience_years", 2, [binding: :last])
      iex> inspect(result)
      "dynamic([c], c.experience_years > ^2)"
  """

  @spec not_lte_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_lte_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [_, ..., c],
          field(c, ^key) > ^value
        )
      else
        dynamic(
          [c],
          field(c, ^key) > ^value
        )
      end
    else
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [q],
          field(q, ^key) > ^value
        )
      else
        dynamic(
          [q],
          field(q, ^key) > ^value
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not less than the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `opts`      - Options related to query bindings

  ### Examples

      iex> result = #{__MODULE__}.not_lt_dynamic("experience_years", 2, [binding: :last])
      iex> inspect(result)
      "dynamic([_, ..., c], c.experience_years > ^2)"
  """

  @spec not_lt_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_lt_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [_, ..., c],
          field(c, ^key) > ^value
        )
      else
        dynamic(
          [_, ..., c],
          field(c, ^key) > ^value
        )
      end
    else
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [q],
          field(q, ^key) > ^value
        )
      else
        dynamic(
          [q],
          field(q, ^key) > ^value
        )
      end
    end
  end

  @doc """

  Builds a dynamic query where field not matches the value substring.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `opts`      - Options related to query bindings
  """

  @spec not_ilike_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_ilike_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        not ilike(
          fragment("(?)::TEXT", field(c, ^key)),
          ^value
        )
      )
    else
      dynamic(
        [q],
        not ilike(
          fragment("(?)::TEXT", field(q, ^key)),
          ^value
        )
      )
    end
  end

  @doc """
  Builds a dynamic query where field not matches the value substring.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `opts`      - Options related to query bindings
  """

  @spec not_like_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_like_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        not like(
          fragment("(?)::TEXT", field(c, ^key)),
          ^value
        )
      )
    else
      dynamic(
        [q],
        not like(
          fragment("(?)::TEXT", field(q, ^key)),
          ^value
        )
      )
    end
  end

  @doc """
  Builds a dynamic query where field is not equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `opts`      - Options related to query bindings

  ### Examples

       iex> result = #{__MODULE__}.not_eq_dynamic("experience_years", 2)
       iex> inspect(result)
       "dynamic([q], q.experience_years != ^2)"
  """

  @spec not_eq_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_eq_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) != ^value
      )
    else
      dynamic(
        [q],
        field(q, ^key) != ^value
      )
    end
  end

  @doc """
  Builds a dynamic query where field is equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `opts`      - Options related to query bindings

  ### Examples

       iex> result = #{__MODULE__}.eq_dynamic("experience_years", 2)
       iex> inspect(result)
       "dynamic([q], q.experience_years == ^2)"
  """

  @spec eq_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def eq_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) == ^value
      )
    else
      dynamic(
        [q],
        field(q, ^key) == ^value
      )
    end
  end

  @doc """
  Builds a dynamic query where value is not between the provided attributes.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Values of the field as a list.
     - `opts`      - Options related to query bindings

  ### Examples

      iex> result = #{__MODULE__}.not_between_dynamic("experience_years", [2, 5])
      iex> inspect(result)
      "dynamic([q], (q.experience_years < ^2 or q.experience_years > ^5))"
  """

  @spec not_between_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_between_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) < ^Enum.min(values) or
          field(c, ^key) > ^Enum.max(values)
      )
    else
      dynamic(
        [q],
        field(q, ^key) < ^Enum.min(values) or
          field(q, ^key) > ^Enum.max(values)
      )
    end
  end

  @doc """
  Builds a dynamic query where value is not equal and between the provided attributes.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Values of the field as a list.
     - `opts`      - Options related to query bindings

  ### Examples

      iex> result = #{__MODULE__}.not_between_equal_dynamic("experience_years", [2, 5])
      iex> inspect(result)
      "dynamic([q], (q.experience_years <= ^2 or q.experience_years >= ^5))"

  """

  @spec not_between_equal_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_between_equal_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) <= ^Enum.min(values) or
          field(c, ^key) >= ^Enum.max(values)
      )
    else
      dynamic(
        [q],
        field(q, ^key) <= ^Enum.min(values) or
          field(q, ^key) >= ^Enum.max(values)
      )
    end
  end

  @doc """
  Builds a dynamic query where value is not in the the list attributes.
  ### Parameters

     - `key`       - Field name.
     - `values`    - Pass a list of values of the field that represent range.
     - `opts`      - Options related to query bindings


  ### Examples

      iex> result = #{__MODULE__}.not_in_dynamic("experience_years", [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years not in ^[2, 5])"

  """

  @spec not_in_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_in_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) not in ^values
      )
    else
      dynamic(
        [q],
        field(q, ^key) not in ^values
      )
    end
  end

  @doc """
  Builds a dynamic query when value of jsonb field is not in the list.
  ### Parameters

     - `key`       - Field name.
     - `values`    - values of jsonb field.
     - `opts`      - Options related to query bindings
  """

  @spec not_contains_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_contains_dynamic(key, values, opts \\ []) do
    # value = Enum.join(value, " ")
    # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        not fragment("? @> ?", field(c, ^key), ^values)
      )
    else
      dynamic(
        [q],
        not fragment("? @> ?", field(q, ^key), ^values)
      )
    end
  end

  @doc """
  Builds a dynamic query when value of jsonb not matches with any list attribute.
  ### Parameters

     - `key`       - Field name.
     - `values`    - values of jsonb field.
     - `opts`      - Options related to query bindings
  """

  @spec not_contains_any_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_contains_any_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        not fragment("? && ?", field(c, ^key), ^values)
      )
    else
      dynamic(
        [q],
        not fragment("? && ?", field(q, ^key), ^values)
      )
    end
  end
end
