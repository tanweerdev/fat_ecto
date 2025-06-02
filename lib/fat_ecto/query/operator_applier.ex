defmodule FatEcto.Query.OperatorApplier do
  @moduledoc """
  Provides helper functions to apply dynamic query operators for Ecto queries.

  This module centralizes the logic for applying various query operators such as `$LIKE`, `$ILIKE`, `$LT`, `$GT`, etc.,
  as well as their negated counterparts (e.g., `$NOT_LIKE`, `$NOT_ILIKE`). It is designed to work with `FatDynamics` and
  `FatNotDynamics` modules to generate dynamic Ecto query conditions.

  ## Supported Operators

  ### Positive Operators
  - `$LIKE`: Matches a pattern in a string.
  - `$NOT_LIKE`: Excludes rows that match a pattern in a string.
  - `$ILIKE`: Case-insensitive match of a pattern in a string.
  - `$NOT_ILIKE`: Case-insensitive exclusion of rows that match a pattern in a string.
  - `$LT`: Less than.
  - `$LTE`: Less than or equal to.
  - `$GT`: Greater than.
  - `$GTE`: Greater than or equal to.
  - `$BETWEEN`: Matches values between a range (exclusive).
  - `$BETWEEN_EQUAL`: Matches values between a range (inclusive).
  - `$NOT_BETWEEN`: Excludes values between a range (exclusive).
  - `$NOT_BETWEEN_EQUAL`: Excludes values between a range (inclusive).
  - `$IN`: Matches values in a list.
  - `$NOT_IN`: Excludes values in a list.
  - `$EQUAL`: Matches a specific value.
  - `$NOT_EQUAL`: Excludes a specific value.

  ### Negated Operators (for `$NOT` conditions)
  - `$LIKE`: Negates the `$LIKE` condition.
  - `$ILIKE`: Negates the `$ILIKE` condition.
  - `$LT`: Negates the `$LT` condition.
  - `$LTE`: Negates the `$LTE` condition.
  - `$GT`: Negates the `$GT` condition.
  - `$GTE`: Negates the `$GTE` condition.
  - `$EQUAL`: Negates the `$EQUAL` condition.

  ## Usage

  This module is typically used internally by `FatEcto.FatQuery.FatWhere` and `FatEcto.FatQuery.WhereOr` to construct
  dynamic queries. It abstracts away the complexity of applying operators and ensures consistency across the codebase.

  ### Example

      # Applying a `$LIKE` operator
      OperatorApplier.apply_operator("$LIKE", :name, "%John%", [])

      # Applying a negated `$EQUAL` operator
      OperatorApplier.apply_not_condition("$EQUAL", :age, 30, [])
  """
  alias FatEcto.Query.Dynamics.BtwInContains
  alias FatEcto.Query.Dynamics.GtLtEq
  alias FatEcto.Query.Dynamics.Like
  alias FatEcto.SharedHelper

  @spec allowed_operators() :: [String.t(), ...]
  def allowed_operators,
    do: [
      "$LIKE",
      "$NOT_LIKE",
      "$ILIKE",
      "$NOT_ILIKE",
      "$NULL",
      "$NOT_NULL",
      "$CAST_TO_DATE_EQUAL",
      "$CAST_TO_DATE_GTE",
      "$CAST_TO_DATE_GT",
      "$CAST_TO_DATE_LT",
      "$CAST_TO_DATE_LTE",
      "$LT",
      "$LTE",
      "$GT",
      "$GTE",
      "$BETWEEN",
      "$BETWEEN_EQUAL",
      "$NOT_BETWEEN",
      "$NOT_BETWEEN_EQUAL",
      "$IN",
      "$NOT_IN",
      "$EQUAL",
      "$NOT_EQUAL"
    ]

  @spec apply_nil_operator(String.t(), atom()) :: nil | Ecto.Query.dynamic_expr()
  def apply_nil_operator("$NULL", field) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.field_is_nil_dynamic(field)
  end

  def apply_nil_operator("$NOT_NULL", field) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.not_field_is_nil_dynamic(field)
  end

  # Helper function to apply the appropriate operator to the field and value.
  @spec apply_operator(String.t(), atom(), any()) :: nil | Ecto.Query.dynamic_expr()
  def apply_operator("$LIKE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    Like.like_dynamic(field, value)
  end

  def apply_operator("$NULL", field, _value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.field_is_nil_dynamic(field)
  end

  def apply_operator("$NOT_LIKE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    Like.not_like_dynamic(field, value)
  end

  def apply_operator("$ILIKE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    Like.ilike_dynamic(field, value)
  end

  def apply_operator("$NOT_ILIKE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    Like.not_ilike_dynamic(field, value)
  end

  def apply_operator("$LT", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.lt_dynamic(field, value)
  end

  def apply_operator("$LTE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.lte_dynamic(field, value)
  end

  def apply_operator("$GT", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.gt_dynamic(field, value)
  end

  def apply_operator("$GTE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.gte_dynamic(field, value)
  end

  def apply_operator("$BETWEEN", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    BtwInContains.between_dynamic(field, value)
  end

  def apply_operator("$BETWEEN_EQUAL", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    BtwInContains.between_equal_dynamic(field, value)
  end

  def apply_operator("$NOT_BETWEEN", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    BtwInContains.not_between_dynamic(field, value)
  end

  def apply_operator("$NOT_BETWEEN_EQUAL", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    BtwInContains.not_between_equal_dynamic(field, value)
  end

  def apply_operator("$IN", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    BtwInContains.in_dynamic(field, value)
  end

  def apply_operator("$NOT_IN", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    BtwInContains.not_in_dynamic(field, value)
  end

  def apply_operator("$EQUAL", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.eq_dynamic(field, value)
  end

  def apply_operator("$CAST_TO_DATE_LT", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.cast_to_date_lt_dynamic(field, value)
  end

  def apply_operator("$CAST_TO_DATE_LTE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.cast_to_date_lte_dynamic(field, value)
  end

  def apply_operator("$CAST_TO_DATE_GT", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.cast_to_date_gt_dynamic(field, value)
  end

  def apply_operator("$CAST_TO_DATE_GTE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.cast_to_date_gte_dynamic(field, value)
  end

  def apply_operator("$CAST_TO_DATE_EQUAL", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.cast_to_date_eq_dynamic(field, value)
  end

  def apply_operator("$NOT_EQUAL", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.not_eq_dynamic(field, value)
  end

  def apply_operator(_, _field, _value), do: nil

  @spec allowed_not_operators() :: [String.t(), ...]
  def allowed_not_operators, do: ["$LIKE", "$ILIKE", "$ILIKE", "$LT", "$LTE", "$GT", "$GTE", "$EQUAL"]
  # Pattern matching for apply_not_condition
  @spec apply_not_condition(String.t(), atom(), any()) :: nil | Ecto.Query.dynamic_expr()
  def apply_not_condition("$LIKE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    Like.not_like_dynamic(field, value)
  end

  def apply_not_condition("$ILIKE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    Like.not_ilike_dynamic(field, value)
  end

  def apply_not_condition("$LT", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.not_lt_dynamic(field, value)
  end

  def apply_not_condition("$LTE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.not_lte_dynamic(field, value)
  end

  def apply_not_condition("$GT", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.not_gt_dynamic(field, value)
  end

  def apply_not_condition("$GTE", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.not_gte_dynamic(field, value)
  end

  def apply_not_condition("$EQUAL", field, value) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.not_eq_dynamic(field, value)
  end

  def apply_not_condition(_operator, _field, _value), do: nil
end
