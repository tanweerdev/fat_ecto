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
  - `$NULL`: Matches rows where the field is null.
  - `$NOT_NULL`: Matches rows where the field is not null.
  - `$CAST_TO_DATE_EQUAL`: Casts field to date and matches a specific date value.
  - `$CAST_TO_DATE_NOT_EQUAL`: Casts field to date and excludes a specific date value.
  - `$CAST_TO_DATE_GTE`: Casts field to date and matches dates greater than or equal to a value.
  - `$CAST_TO_DATE_GT`: Casts field to date and matches dates greater than a value.
  - `$CAST_TO_DATE_LT`: Casts field to date and matches dates less than a value.
  - `$CAST_TO_DATE_LTE`: Casts field to date and matches dates less than or equal to a value.
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

  ## Join Filters (Named Bindings)

  All operators support an optional `binding` parameter for filtering on joined tables.
  When a binding is provided, the dynamic uses a named binding instead of the default `[q]`.

      # Direct filter (no binding)
      OperatorApplier.apply_operator("$EQUAL", :name, "John")
      # => dynamic([q], q.name == ^"John")

      # Join filter (with binding)
      OperatorApplier.apply_operator("$EQUAL", :subject_id, "uuid", :classifications)
      # => dynamic([classifications: j], j.subject_id == ^"uuid")

  ## Usage

  This module is typically used internally by `FatEcto.FatQuery.FatWhere` and `FatEcto.FatQuery.WhereOr` to construct
  dynamic queries. It abstracts away the complexity of applying operators and ensures consistency across the codebase.

  ### Example

      # Applying a `$LIKE` operator
      OperatorApplier.apply_operator("$LIKE", :name, "%John%")

      # Applying a negated `$EQUAL` operator
      OperatorApplier.apply_not_condition("$EQUAL", :age, 30)

      # Applying a `$EQUAL` operator on a joined table
      OperatorApplier.apply_operator("$EQUAL", :subject_id, "uuid", :classifications)
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
      "$CAST_TO_DATE_NOT_EQUAL",
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
  def apply_nil_operator(operator, field) do
    operator = String.upcase(operator)
    do_apply_nil_operator(operator, field)
  end

  defp do_apply_nil_operator("$NULL", field) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.field_is_nil_dynamic(field)
  end

  defp do_apply_nil_operator("$NOT_NULL", field) do
    field = SharedHelper.string_to_existing_atom(field)
    GtLtEq.not_field_is_nil_dynamic(field)
  end

  # Helper function to apply the appropriate operator to the field and value.
  # Optional binding parameter for join filters (named bindings).
  @spec apply_operator(String.t(), atom() | String.t(), any(), atom() | nil) ::
          nil | Ecto.Query.dynamic_expr()
  def apply_operator(operator, field, value, binding \\ nil) do
    operator = String.upcase(operator)
    field = SharedHelper.string_to_existing_atom(field)
    do_apply_operator(operator, field, value, binding)
  end

  # Delegates to dynamics modules with binding parameter
  # The modules handle both direct filters (binding=nil) and join filters (binding=atom)

  @spec do_apply_operator(String.t(), atom(), any(), atom() | nil) ::
          nil | Ecto.Query.dynamic_expr()
  defp do_apply_operator("$LIKE", field, value, binding) do
    Like.like_dynamic(field, value, binding)
  end

  defp do_apply_operator("$NULL", field, _value, binding) do
    GtLtEq.field_is_nil_dynamic(field, binding)
  end

  defp do_apply_operator("$NOT_NULL", field, _value, binding) do
    GtLtEq.not_field_is_nil_dynamic(field, binding)
  end

  defp do_apply_operator("$NOT_LIKE", field, value, binding) do
    Like.not_like_dynamic(field, value, binding)
  end

  defp do_apply_operator("$ILIKE", field, value, binding) do
    Like.ilike_dynamic(field, value, binding)
  end

  defp do_apply_operator("$NOT_ILIKE", field, value, binding) do
    Like.not_ilike_dynamic(field, value, binding)
  end

  defp do_apply_operator("$LT", field, value, binding) do
    GtLtEq.lt_dynamic(field, value, binding)
  end

  defp do_apply_operator("$LTE", field, value, binding) do
    GtLtEq.lte_dynamic(field, value, binding)
  end

  defp do_apply_operator("$GT", field, value, binding) do
    GtLtEq.gt_dynamic(field, value, binding)
  end

  defp do_apply_operator("$GTE", field, value, binding) do
    GtLtEq.gte_dynamic(field, value, binding)
  end

  defp do_apply_operator("$BETWEEN", field, value, binding) do
    BtwInContains.between_dynamic(field, value, binding)
  end

  defp do_apply_operator("$BETWEEN_EQUAL", field, value, binding) do
    BtwInContains.between_equal_dynamic(field, value, binding)
  end

  defp do_apply_operator("$NOT_BETWEEN", field, value, binding) do
    BtwInContains.not_between_dynamic(field, value, binding)
  end

  defp do_apply_operator("$NOT_BETWEEN_EQUAL", field, value, binding) do
    BtwInContains.not_between_equal_dynamic(field, value, binding)
  end

  defp do_apply_operator("$IN", field, value, binding) do
    BtwInContains.in_dynamic(field, value, binding)
  end

  defp do_apply_operator("$NOT_IN", field, value, binding) do
    BtwInContains.not_in_dynamic(field, value, binding)
  end

  defp do_apply_operator("$EQUAL", field, value, binding) do
    GtLtEq.eq_dynamic(field, value, binding)
  end

  defp do_apply_operator("$NOT_EQUAL", field, value, binding) do
    GtLtEq.not_eq_dynamic(field, value, binding)
  end

  defp do_apply_operator("$CAST_TO_DATE_LT", field, value, binding) do
    val = SharedHelper.to_date!(value)
    GtLtEq.cast_to_date_lt_dynamic(field, val, binding)
  end

  defp do_apply_operator("$CAST_TO_DATE_LTE", field, value, binding) do
    val = SharedHelper.to_date!(value)
    GtLtEq.cast_to_date_lte_dynamic(field, val, binding)
  end

  defp do_apply_operator("$CAST_TO_DATE_GT", field, value, binding) do
    val = SharedHelper.to_date!(value)
    GtLtEq.cast_to_date_gt_dynamic(field, val, binding)
  end

  defp do_apply_operator("$CAST_TO_DATE_GTE", field, value, binding) do
    val = SharedHelper.to_date!(value)
    GtLtEq.cast_to_date_gte_dynamic(field, val, binding)
  end

  defp do_apply_operator("$CAST_TO_DATE_EQUAL", field, value, binding) do
    val = SharedHelper.to_date!(value)
    GtLtEq.cast_to_date_eq_dynamic(field, val, binding)
  end

  defp do_apply_operator("$CAST_TO_DATE_NOT_EQUAL", field, value, binding) do
    val = SharedHelper.to_date!(value)
    GtLtEq.cast_to_date_not_eq_dynamic(field, val, binding)
  end

  defp do_apply_operator(_, _field, _value, _binding), do: nil

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
