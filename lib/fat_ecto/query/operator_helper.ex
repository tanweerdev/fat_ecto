defmodule FatEcto.FatQuery.OperatorHelper do
  alias FatEcto.FatQuery.FatDynamics
  alias FatEcto.FatQuery.FatNotDynamics

  @spec allowed_operators() :: [String.t(), ...]
  def allowed_operators,
    do: [
      "$like",
      "$not_like",
      "$ilike",
      "$not_ilike",
      "$lt",
      "$lte",
      "$gt",
      "$gte",
      "$between",
      "$between_equal",
      "$not_between",
      "$not_between_equal",
      "$in",
      "$not_in",
      "$equal",
      "$not_equal"
    ]

  # Helper function to apply the appropriate operator to the field and value.
  @spec apply_operator(String.t(), atom(), any(), Keyword.t()) :: nil | %Ecto.Query.DynamicExpr{}
  def apply_operator("$like", field, value, opts),
    do: FatDynamics.like_dynamic(field, value, opts)

  def apply_operator("$not_like", field, value, opts),
    do: FatNotDynamics.not_like_dynamic(field, value, opts)

  def apply_operator("$ilike", field, value, opts),
    do: FatDynamics.ilike_dynamic(field, value, opts)

  def apply_operator("$not_ilike", field, value, opts),
    do: FatNotDynamics.not_ilike_dynamic(field, value, opts)

  def apply_operator("$lt", field, value, opts),
    do: FatDynamics.lt_dynamic(field, value, opts)

  def apply_operator("$lte", field, value, opts),
    do: FatDynamics.lte_dynamic(field, value, opts)

  def apply_operator("$gt", field, value, opts),
    do: FatDynamics.gt_dynamic(field, value, opts)

  def apply_operator("$gte", field, value, opts),
    do: FatDynamics.gte_dynamic(field, value, opts)

  def apply_operator("$between", field, value, opts),
    do: FatDynamics.between_dynamic(field, value, opts)

  def apply_operator("$between_equal", field, value, opts),
    do: FatDynamics.between_equal_dynamic(field, value, opts)

  def apply_operator("$not_between", field, value, opts),
    do: FatNotDynamics.not_between_dynamic(field, value, opts)

  def apply_operator("$not_between_equal", field, value, opts),
    do: FatNotDynamics.not_between_equal_dynamic(field, value, opts)

  def apply_operator("$in", field, value, opts),
    do: FatDynamics.in_dynamic(field, value, opts)

  def apply_operator("$not_in", field, value, opts),
    do: FatNotDynamics.not_in_dynamic(field, value, opts)

  def apply_operator("$equal", field, value, opts),
    do: FatDynamics.eq_dynamic(field, value, opts)

  def apply_operator("$not_equal", field, value, opts),
    do: FatDynamics.not_eq_dynamic(field, value, opts)

  def apply_operator(_, _field, _value, _opts), do: nil

  @spec allowed_not_operators() :: [String.t(), ...]
  def allowed_not_operators, do: ["$like", "$ilike", "$ilike", "$lt", "$lte", "$gt", "$gte", "$equal"]
  # Pattern matching for apply_not_condition
  @spec apply_not_condition(String.t(), atom(), any(), Keyword.t()) :: nil | %Ecto.Query.DynamicExpr{}
  def apply_not_condition("$like", field, value, opts) do
    FatNotDynamics.not_like_dynamic(field, value, opts)
  end

  def apply_not_condition("$ilike", field, value, opts) do
    FatNotDynamics.not_ilike_dynamic(field, value, opts)
  end

  def apply_not_condition("$lt", field, value, opts) do
    FatNotDynamics.not_lt_dynamic(field, value, opts)
  end

  def apply_not_condition("$lte", field, value, opts) do
    FatNotDynamics.not_lte_dynamic(field, value, opts)
  end

  def apply_not_condition("$gt", field, value, opts) do
    FatNotDynamics.not_gt_dynamic(field, value, opts)
  end

  def apply_not_condition("$gte", field, value, opts) do
    FatNotDynamics.not_gte_dynamic(field, value, opts)
  end

  def apply_not_condition("$equal", field, value, opts) do
    FatNotDynamics.not_eq_dynamic(field, value, opts)
  end

  def apply_not_condition(_operator, _field, _value, _opts), do: nil
end
