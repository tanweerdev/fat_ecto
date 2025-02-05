defmodule FatEcto.FatQuery.OperatorHelper do
  @moduledoc """
  Provides helper functions to apply dynamic query operators for Ecto queries.

  This module centralizes the logic for applying various query operators such as `$like`, `$ilike`, `$lt`, `$gt`, etc.,
  as well as their negated counterparts (e.g., `$not_like`, `$not_ilike`). It is designed to work with `FatDynamics` and
  `FatNotDynamics` modules to generate dynamic Ecto query conditions.

  ## Supported Operators

  ### Positive Operators
  - `$like`: Matches a pattern in a string.
  - `$not_like`: Excludes rows that match a pattern in a string.
  - `$ilike`: Case-insensitive match of a pattern in a string.
  - `$not_ilike`: Case-insensitive exclusion of rows that match a pattern in a string.
  - `$lt`: Less than.
  - `$lte`: Less than or equal to.
  - `$gt`: Greater than.
  - `$gte`: Greater than or equal to.
  - `$between`: Matches values between a range (exclusive).
  - `$between_equal`: Matches values between a range (inclusive).
  - `$not_between`: Excludes values between a range (exclusive).
  - `$not_between_equal`: Excludes values between a range (inclusive).
  - `$in`: Matches values in a list.
  - `$not_in`: Excludes values in a list.
  - `$equal`: Matches a specific value.
  - `$not_equal`: Excludes a specific value.

  ### Negated Operators (for `$not` conditions)
  - `$like`: Negates the `$like` condition.
  - `$ilike`: Negates the `$ilike` condition.
  - `$lt`: Negates the `$lt` condition.
  - `$lte`: Negates the `$lte` condition.
  - `$gt`: Negates the `$gt` condition.
  - `$gte`: Negates the `$gte` condition.
  - `$equal`: Negates the `$equal` condition.

  ## Usage

  This module is typically used internally by `FatEcto.FatQuery.FatWhere` and `FatEcto.FatQuery.WhereOr` to construct
  dynamic queries. It abstracts away the complexity of applying operators and ensures consistency across the codebase.

  ### Example

      # Applying a `$like` operator
      OperatorHelper.apply_operator("$like", :name, "%John%", [])

      # Applying a negated `$equal` operator
      OperatorHelper.apply_not_condition("$equal", :age, 30, [])
  """

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
