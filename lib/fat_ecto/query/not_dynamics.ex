defmodule FatEcto.FatQuery.FatNotDynamics do
  @moduledoc """
  Builds a `where query` using dynamics and not condition.

  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Where query options as a map.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "location", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>      "name" => "%John%",
      ...>      "location" => nil,
      ...>      "rating" => "$not_null",
      ...>      "total_staff" => %{"$between" => [1, 3]}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff > ^1 and f0.total_staff < ^3 and (not(is_nil(f0.rating)) and (f0.name == ^"%John%" and (is_nil(f0.location) and ^true))), select: map(f0, [:name, :location, :rating])>

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
    - `dynamics`  - Default or previous dynamic to append to the query.
    - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples
      iex> result = #{__MODULE__}.not_is_nil_dynamic("location", true, [dynamic_type: :and])
      iex> inspect(result)
      "dynamic([c], not(is_nil(c.location)) and ^true)"
  """
  @spec not_is_nil_dynamic(any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_is_nil_dynamic(key, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [c],
          not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
        )
      else
        dynamic(
          [c],
          not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not greater than the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.not_gt_dynamic("experience_years", 2, true, [dynamic_type: :or, binding: :last])
      iex> inspect(result)
      "dynamic([..., c], c.experience_years < ^2 or ^true)"
  """

  @spec not_gt_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_gt_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not greater than or equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.not_gte_dynamic("experience_years", 2, true, [dynamic_type: :and, binding: :last])
      iex> inspect(result)
      "dynamic([..., c], c.experience_years < ^2 and ^true)"
  """

  @spec not_gte_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_gte_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not less than or equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.not_lte_dynamic("experience_years", 2, true, [dynamic_type: :and, binding: :last])
      iex> inspect(result)
      "dynamic([c], c.experience_years > ^2 and ^true)"
  """

  @spec not_lte_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_lte_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [c],
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
          )
        else
          dynamic(
            [c],
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not less than the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.not_lt_dynamic("experience_years", 2, true, [dynamic_type: :and, binding: :last])
      iex> inspect(result)
      "dynamic([..., c], c.experience_years > ^2 and ^true)"
  """

  @spec not_lt_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_lt_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """

  Builds a dynamic query where field not matches the value substring.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).
  """

  @spec not_ilike_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_ilike_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not ilike(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not ilike(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not ilike(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          not ilike(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field not matches the value substring.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).
  """

  @spec not_like_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_like_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not like(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not like(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not like(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          not like(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

       iex> result = #{__MODULE__}.not_eq_dynamic("experience_years", 2, true, [dynamic_type: :and])
       iex> inspect(result)
       "dynamic([q], q.experience_years != ^2 and ^true)"
  """

  @spec not_eq_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_eq_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) != ^value and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) != ^value or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) != ^value and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) != ^value or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where value is not between the provided attributes.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Values of the field as a list.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.not_between_dynamic("experience_years", [2, 5], true, [dynamic_type: :and])
      iex> inspect(result)
      "dynamic([q], (q.experience_years < ^2 or q.experience_years > ^5) and ^true)"
  """

  @spec not_between_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_between_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          (field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
             field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values)) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          (field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
             field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values)) and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where value is not equal and between the provided attributes.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Values of the field as a list.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.not_between_equal_dynamic("experience_years", [2, 5], true, [dynamic_type: :and])
      iex> inspect(result)
      "dynamic([q], (q.experience_years <= ^2 or q.experience_years >= ^5) and ^true)"

  """

  @spec not_between_equal_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_between_equal_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          (field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
             field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values)) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
            field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          (field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
             field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values)) and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
            field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where value is not in the the list attributes.
  ### Parameters

     - `key`       - Field name.
     - `values`    - Pass a list of values of the field that represent range.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).


  ### Examples

      iex> result = #{__MODULE__}.not_in_dynamic("experience_years", [2, 5], true, [dynamic_type: :and])
      iex> inspect(result)
      "dynamic([q], q.experience_years not in ^[2, 5] and ^true)"

  """

  @spec not_in_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_in_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) not in ^values and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) not in ^values or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) not in ^values and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) not in ^values or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query when value of jsonb field is not in the list.
  ### Parameters

     - `key`       - Field name.
     - `values`    - values of jsonb field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).
  """

  @spec not_contains_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_contains_dynamic(key, values, dynamics, opts \\ []) do
    # value = Enum.join(value, " ")
    # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [q],
          not fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query when value of jsonb not matches with any list attribute.
  ### Parameters

     - `key`       - Field name.
     - `values`    - values of jsonb field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).
  """

  @spec not_contains_any_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_contains_any_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [q],
          not fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    end
  end
end
