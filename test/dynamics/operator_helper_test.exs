defmodule FatEcto.Dynamics.FatOperatorHelperTest do
  use FatEcto.ConnCase
  alias FatEcto.Dynamics.FatDynamics
  alias FatEcto.Dynamics.FatNotDynamics
  alias FatEcto.Dynamics.FatOperatorHelper

  describe "apply_operator/4" do
    test "applies $LIKE operator" do
      result = FatOperatorHelper.apply_operator("$LIKE", :name, "%John%", [])
      assert result == FatDynamics.like_dynamic(:name, "%John%", [])
    end

    test "applies $NOT_LIKE operator" do
      result = FatOperatorHelper.apply_operator("$NOT_LIKE", :name, "%John%", [])
      assert result == FatNotDynamics.not_like_dynamic(:name, "%John%", [])
    end

    test "applies $ILIKE operator" do
      result = FatOperatorHelper.apply_operator("$ILIKE", :name, "%John%", [])
      assert result == FatDynamics.ilike_dynamic(:name, "%John%", [])
    end

    test "applies $NOT_ILIKE operator" do
      result = FatOperatorHelper.apply_operator("$NOT_ILIKE", :name, "%John%", [])
      assert result == FatNotDynamics.not_ilike_dynamic(:name, "%John%", [])
    end

    test "applies $LT operator" do
      result = FatOperatorHelper.apply_operator("$LT", :age, 30, [])
      assert result == FatDynamics.lt_dynamic(:age, 30, [])
    end

    test "applies $LTE operator" do
      result = FatOperatorHelper.apply_operator("$LTE", :age, 30, [])
      assert result == FatDynamics.lte_dynamic(:age, 30, [])
    end

    test "applies $GT operator" do
      result = FatOperatorHelper.apply_operator("$GT", :age, 30, [])
      assert result == FatDynamics.gt_dynamic(:age, 30, [])
    end

    test "applies $GTE operator" do
      result = FatOperatorHelper.apply_operator("$GTE", :age, 30, [])
      assert result == FatDynamics.gte_dynamic(:age, 30, [])
    end

    test "applies $BETWEEN operator" do
      result = FatOperatorHelper.apply_operator("$BETWEEN", :age, [20, 30], [])
      assert result == FatDynamics.between_dynamic(:age, [20, 30], [])
    end

    test "applies $NOT_BETWEEN operator" do
      result = FatOperatorHelper.apply_operator("$NOT_BETWEEN", :age, [20, 30], [])
      assert result == FatNotDynamics.not_between_dynamic(:age, [20, 30], [])
    end

    test "applies $IN operator" do
      result = FatOperatorHelper.apply_operator("$IN", :age, [20, 30], [])
      assert result == FatDynamics.in_dynamic(:age, [20, 30], [])
    end

    test "applies $NOT_IN operator" do
      result = FatOperatorHelper.apply_operator("$NOT_IN", :age, [20, 30], [])
      assert result == FatNotDynamics.not_in_dynamic(:age, [20, 30], [])
    end

    test "applies $EQUAL operator" do
      result = FatOperatorHelper.apply_operator("$EQUAL", :age, 30, [])
      assert result == FatDynamics.eq_dynamic(:age, 30, [])
    end

    test "applies $NOT_EQUAL operator" do
      result = FatOperatorHelper.apply_operator("$NOT_EQUAL", :age, 30, [])
      assert result == FatDynamics.not_eq_dynamic(:age, 30, [])
    end

    test "returns nil for unsupported operator" do
      result = FatOperatorHelper.apply_operator("$unsupported", :age, 30, [])
      assert result == nil
    end
  end

  describe "apply_not_condition/4" do
    test "applies negated $LIKE operator" do
      result = FatOperatorHelper.apply_not_condition("$LIKE", :name, "%John%", [])
      assert result == FatNotDynamics.not_like_dynamic(:name, "%John%", [])
    end

    test "applies negated $ILIKE operator" do
      result = FatOperatorHelper.apply_not_condition("$ILIKE", :name, "%John%", [])
      assert result == FatNotDynamics.not_ilike_dynamic(:name, "%John%", [])
    end

    test "applies negated $LT operator" do
      result = FatOperatorHelper.apply_not_condition("$LT", :age, 30, [])
      assert result == FatNotDynamics.not_lt_dynamic(:age, 30, [])
    end

    test "applies negated $LTE operator" do
      result = FatOperatorHelper.apply_not_condition("$LTE", :age, 30, [])
      assert result == FatNotDynamics.not_lte_dynamic(:age, 30, [])
    end

    test "applies negated $GT operator" do
      result = FatOperatorHelper.apply_not_condition("$GT", :age, 30, [])
      assert result == FatNotDynamics.not_gt_dynamic(:age, 30, [])
    end

    test "applies negated $GTE operator" do
      result = FatOperatorHelper.apply_not_condition("$GTE", :age, 30, [])
      assert result == FatNotDynamics.not_gte_dynamic(:age, 30, [])
    end

    test "applies negated $EQUAL operator" do
      result = FatOperatorHelper.apply_not_condition("$EQUAL", :age, 30, [])
      assert result == FatNotDynamics.not_eq_dynamic(:age, 30, [])
    end

    test "returns nil for unsupported negated operator" do
      result = FatOperatorHelper.apply_not_condition("$unsupported", :age, 30, [])
      assert result == nil
    end
  end
end
