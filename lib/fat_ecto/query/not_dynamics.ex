defmodule FatEcto.FatQuery.FatNotDynamics do
  import Ecto.Query
  alias FatEcto.FatHelper

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

  @spec not_contains_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_contains_dynamic(key, values, dynamics, opts \\ []) do
    # value = Enum.join(value, " ")
    # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and
            ^dynamics
        )
      else
        dynamic(
          [..., c],
          not fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or
            ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and
            ^dynamics
        )
      else
        dynamic(
          [q],
          not fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or
            ^dynamics
        )
      end
    end
  end

  @spec not_contains_any_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_contains_any_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and
            ^dynamics
        )
      else
        dynamic(
          [..., c],
          not fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or
            ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and
            ^dynamics
        )
      else
        dynamic(
          [q],
          not fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or
            ^dynamics
        )
      end
    end
  end
end
