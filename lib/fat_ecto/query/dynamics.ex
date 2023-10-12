defmodule FatEcto.FatQuery.FatDynamics do
  @moduledoc """
  Builds a `where query` using dynamics.

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
      iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff > ^1 and f0.total_staff < ^3 and\n  (not is_nil(f0.rating) and (f0.name == ^\"%John%\" and (is_nil(f0.location) and ^true))), select: map(f0, [:name, :location, :rating])>

  ### Options

    - `$select` - Select the fields from `hospital` and `rooms`.
    - `$where`  - Added the where attribute in the query.
  """
  import Ecto.Query
  alias FatEcto.FatHelper

  @doc """
   Builds a dynamic query where field is nil.
  ### Parameters

    - `key`       - Field name .
    - `dynamics`  - Default or previous dynamic to append to the query.
    - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples
      iex> result = #{__MODULE__}.is_nil_dynamic("location", true, [dynamic_type: :and])
      iex> inspect(result)
      "dynamic([c], is_nil(c.location) and ^true)"
  """

  @spec is_nil_dynamic(any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def is_nil_dynamic(key, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [c],
          is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
        )
      else
        dynamic(
          [c],
          is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field is greater than the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.gt_dynamic("experience_years", 2, true, [dynamic_type: :or, binding: :last])
      iex> inspect(result)
      "dynamic([..., c], c.experience_years > ^2 or ^true)"
  """

  @spec gt_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def gt_dynamic(key, value, dynamics, opts \\ []) do
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
  Builds a dynamic query where field is greater than and equal to given value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.gte_dynamic("experience_years", 2, true, [dynamic_type: :and, binding: :last])
      iex> inspect(result)
      "dynamic([..., c], c.experience_years >= ^2 and ^true)"
  """

  @spec gte_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def gte_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >=
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >=
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >= ^value and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >= ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >=
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >=
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >= ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >= ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where field is less than and equal to the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.lte_dynamic("experience_years", 2, true, [dynamic_type: :or])
      iex> inspect(result)
      "dynamic([q], q.experience_years <= ^2 or ^true)"

  """

  @spec lte_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def lte_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <=
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <=
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <= ^value and ^dynamics
          )
        else
          dynamic(
            [c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <= ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <=
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <=
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <= ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <= ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where field is less than the value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.lt_dynamic("experience_years", 2, true, [dynamic_type: :and, binding: :last])
      iex> inspect(result)
      "dynamic([..., c], c.experience_years < ^2 and ^true)"
  """

  @spec lt_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def lt_dynamic(key, value, dynamics, opts \\ []) do
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
   Builds a dynamic query where field matches the value substring.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  """

  @spec ilike_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def ilike_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          ilike(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          ilike(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          ilike(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          ilike(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    end
  end

  def array_ilike_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          fragment(
            "exists (SELECT 1 FROM unnest(?) as value WHERE value ILIKE ?)",
            field(c, ^FatHelper.string_to_existing_atom(key)),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          fragment(
            "exists (SELECT 1 FROM unnest(?) as value WHERE value ILIKE ?)",
            field(c, ^FatHelper.string_to_existing_atom(key)),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          fragment(
            "exists (SELECT 1 FROM unnest(?) as value WHERE value ILIKE ?)",
            field(q, ^FatHelper.string_to_existing_atom(key)),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          fragment(
            "exists (SELECT 1 FROM unnest(?) as value WHERE value ILIKE ?)",
            field(q, ^FatHelper.string_to_existing_atom(key)),
            ^value
          ) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field matches matches the value substring.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  """

  @spec like_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def like_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          like(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          like(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          like(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          like(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field is equal to value.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

       iex> result = #{__MODULE__}.eq_dynamic("experience_years", 2, true, [dynamic_type: :and])
       iex> inspect(result)
       "dynamic([q], q.experience_years == ^2 and ^true)"
  """

  @spec eq_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def eq_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) == ^value and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) == ^value or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) == ^value and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) == ^value or ^dynamics
        )
      end
    end
  end

  @spec not_eq_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_eq_dynamic(key, value, dynamics, opts \\ []) do
    value =
      if is_map(value) do
        %{"$not_equal" => v} = value
        v
      else
        value
      end

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
  Builds a dynamic query where value is between the provided attributes.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Values of the field as a list.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.between_dynamic("experience_years", [2, 5], true, [dynamic_type: :and])
      iex> inspect(result)
      "dynamic([q], q.experience_years > ^2 and q.experience_years < ^5 and ^true)"
  """

  @spec between_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def between_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          (field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
             field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values)) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values) and ^dynamics
        )
      else
        dynamic(
          [q],
          (field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
             field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values)) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where value equal and between the provided attributes.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Values of the field as a list.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  ### Examples

      iex> result = #{__MODULE__}.between_equal_dynamic("experience_years", [2, 5], true, [dynamic_type: :and])
      iex> inspect(result)
      "dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5 and ^true)"

  """

  @spec between_equal_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def between_equal_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
            field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          (field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
             field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values)) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
            field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values) and ^dynamics
        )
      else
        dynamic(
          [q],
          (field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
             field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values)) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where value is in the the provided list attributes.
  ### Parameters

     - `key`       - Field name.
     - `values`    - Pass a list of values of the field that represent range.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).


  ### Examples

      iex> result = #{__MODULE__}.in_dynamic("experience_years", [2, 5], true, [dynamic_type: :and])
      iex> inspect(result)
      "dynamic([q], q.experience_years in ^[2, 5] and ^true)"

  """

  @spec in_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def in_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) in ^values and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) in ^values or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) in ^values and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) in ^values or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query when value of jsonb field is in the list.
  ### Parameters

     - `key`       - Field name.
     - `values`    - values of jsonb field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  """

  @spec contains_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def contains_dynamic(key, values, dynamics, opts \\ []) do
    # value = Enum.join(value, " ")
    # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [q],
          fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query when value of jsonb matches with any list attribute.
  ### Parameters

     - `key`       - Field name.
     - `values`    - values of jsonb field.
     - `dynamics`  - Default or previous dynamic to append to the query.
     - `opts`      - Options related to query bindings alongwith dynamic type(and/or).

  """

  @spec contains_any_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def contains_any_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [q],
          fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    end
  end
end
