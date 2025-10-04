defmodule FatEcto.Query.OperatorApplierTest do
  use FatEcto.ConnCase
  alias FatEcto.Query.Dynamics.BtwInContains
  alias FatEcto.Query.Dynamics.GtLtEq
  alias FatEcto.Query.Dynamics.Like
  alias FatEcto.Query.OperatorApplier

  describe "apply_operator/4" do
    test "applies $LIKE operator" do
      result = OperatorApplier.apply_operator("$LIKE", :name, "%John%")
      assert result == Like.like_dynamic(:name, "%John%")
    end

    test "applies $NOT_LIKE operator" do
      result = OperatorApplier.apply_operator("$NOT_LIKE", :name, "%John%")
      assert result == Like.not_like_dynamic(:name, "%John%")
    end

    test "applies $ILIKE operator" do
      result = OperatorApplier.apply_operator("$ILIKE", :name, "%John%")
      assert result == Like.ilike_dynamic(:name, "%John%")
    end

    test "applies $NOT_ILIKE operator" do
      result = OperatorApplier.apply_operator("$NOT_ILIKE", :name, "%John%")
      assert result == Like.not_ilike_dynamic(:name, "%John%")
    end

    test "applies $LT operator" do
      result = OperatorApplier.apply_operator("$LT", :age, 30)
      assert result == GtLtEq.lt_dynamic(:age, 30)
    end

    test "applies $LTE operator" do
      result = OperatorApplier.apply_operator("$LTE", :age, 30)
      assert result == GtLtEq.lte_dynamic(:age, 30)
    end

    test "applies $GT operator" do
      result = OperatorApplier.apply_operator("$GT", :age, 30)
      assert result == GtLtEq.gt_dynamic(:age, 30)
    end

    test "applies $GTE operator" do
      result = OperatorApplier.apply_operator("$GTE", :age, 30)
      assert result == GtLtEq.gte_dynamic(:age, 30)
    end

    test "applies $BETWEEN operator" do
      result = OperatorApplier.apply_operator("$BETWEEN", :age, [20, 30])
      assert result == BtwInContains.between_dynamic(:age, [20, 30])
    end

    test "applies $NOT_BETWEEN operator" do
      result = OperatorApplier.apply_operator("$NOT_BETWEEN", :age, [20, 30])
      assert result == BtwInContains.not_between_dynamic(:age, [20, 30])
    end

    test "applies $IN operator" do
      result = OperatorApplier.apply_operator("$IN", :age, [20, 30])
      assert result == BtwInContains.in_dynamic(:age, [20, 30])
    end

    test "applies $NOT_IN operator" do
      result = OperatorApplier.apply_operator("$NOT_IN", :age, [20, 30])
      assert result == BtwInContains.not_in_dynamic(:age, [20, 30])
    end

    test "applies $EQUAL operator" do
      result = OperatorApplier.apply_operator("$EQUAL", :age, 30)
      assert result == GtLtEq.eq_dynamic(:age, 30)
    end

    test "applies $NOT_EQUAL operator" do
      result = OperatorApplier.apply_operator("$NOT_EQUAL", :age, 30)
      assert result == GtLtEq.not_eq_dynamic(:age, 30)
    end

    test "applies $BETWEEN_EQUAL operator" do
      result = OperatorApplier.apply_operator("$BETWEEN_EQUAL", :age, [20, 30])
      assert result == BtwInContains.between_equal_dynamic(:age, [20, 30])
    end

    test "applies $NOT_BETWEEN_EQUAL operator" do
      result = OperatorApplier.apply_operator("$NOT_BETWEEN_EQUAL", :age, [20, 30])
      assert result == BtwInContains.not_between_equal_dynamic(:age, [20, 30])
    end

    test "applies $CAST_TO_DATE_LT operator" do
      date_value = ~D[2023-01-01]
      result = OperatorApplier.apply_operator("$CAST_TO_DATE_LT", :end_date, date_value)
      assert result == GtLtEq.cast_to_date_lt_dynamic(:end_date, date_value)
    end

    test "applies $CAST_TO_DATE_LTE operator" do
      date_value = ~D[2023-01-01]
      result = OperatorApplier.apply_operator("$CAST_TO_DATE_LTE", :end_date, date_value)
      assert result == GtLtEq.cast_to_date_lte_dynamic(:end_date, date_value)
    end

    test "applies $CAST_TO_DATE_GT operator" do
      date_value = ~D[2023-01-01]
      result = OperatorApplier.apply_operator("$CAST_TO_DATE_GT", :end_date, date_value)
      assert result == GtLtEq.cast_to_date_gt_dynamic(:end_date, date_value)
    end

    test "applies $CAST_TO_DATE_GTE operator" do
      date_value = ~D[2023-01-01]
      result = OperatorApplier.apply_operator("$CAST_TO_DATE_GTE", :end_date, date_value)
      assert result == GtLtEq.cast_to_date_gte_dynamic(:end_date, date_value)
    end

    test "applies $CAST_TO_DATE_EQUAL operator" do
      date_value = ~D[2023-01-01]
      result = OperatorApplier.apply_operator("$CAST_TO_DATE_EQUAL", :end_date, date_value)
      assert result == GtLtEq.cast_to_date_eq_dynamic(:end_date, date_value)
    end

    test "applies $CAST_TO_DATE_NOT_EQUAL operator" do
      date_value = ~D[2023-01-01]
      result = OperatorApplier.apply_operator("$CAST_TO_DATE_NOT_EQUAL", :end_date, date_value)
      assert result == GtLtEq.cast_to_date_not_eq_dynamic(:end_date, date_value)
    end

    test "returns nil for unsupported operator" do
      result = OperatorApplier.apply_operator("$unsupported", :age, 30)
      assert result == nil
    end
  end

  describe "apply_nil_operator/2" do
    test "applies $NULL operator" do
      result = OperatorApplier.apply_nil_operator("$NULL", :location)
      assert result == GtLtEq.field_is_nil_dynamic(:location)
    end

    test "applies $NOT_NULL operator" do
      result = OperatorApplier.apply_nil_operator("$NOT_NULL", :location)
      assert result == GtLtEq.not_field_is_nil_dynamic(:location)
    end
  end

  describe "apply_not_condition/4" do
    test "applies negated $LIKE operator" do
      result = OperatorApplier.apply_not_condition("$LIKE", :name, "%John%")
      assert result == Like.not_like_dynamic(:name, "%John%")
    end

    test "applies negated $ILIKE operator" do
      result = OperatorApplier.apply_not_condition("$ILIKE", :name, "%John%")
      assert result == Like.not_ilike_dynamic(:name, "%John%")
    end

    test "applies negated $LT operator" do
      result = OperatorApplier.apply_not_condition("$LT", :age, 30)
      assert result == GtLtEq.not_lt_dynamic(:age, 30)
    end

    test "applies negated $LTE operator" do
      result = OperatorApplier.apply_not_condition("$LTE", :age, 30)
      assert result == GtLtEq.not_lte_dynamic(:age, 30)
    end

    test "applies negated $GT operator" do
      result = OperatorApplier.apply_not_condition("$GT", :age, 30)
      assert result == GtLtEq.not_gt_dynamic(:age, 30)
    end

    test "applies negated $GTE operator" do
      result = OperatorApplier.apply_not_condition("$GTE", :age, 30)
      assert result == GtLtEq.not_gte_dynamic(:age, 30)
    end

    test "applies negated $EQUAL operator" do
      result = OperatorApplier.apply_not_condition("$EQUAL", :age, 30)
      assert result == GtLtEq.not_eq_dynamic(:age, 30)
    end

    test "returns nil for unsupported negated operator" do
      result = OperatorApplier.apply_not_condition("$unsupported", :age, 30)
      assert result == nil
    end
  end
end
