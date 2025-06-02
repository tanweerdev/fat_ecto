defmodule FatEcto.Query.Dynamics.GtLtEqTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  alias FatEcto.Query.Dynamics.GtLtEq

  describe "field_is_nil_dynamic/3" do
    test "builds a dynamic query for nil field with :and logic" do
      result = GtLtEq.field_is_nil_dynamic(:location)
      expected = dynamic([q], is_nil(q.location))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for nil field with :or logic" do
      result = GtLtEq.field_is_nil_dynamic(:location)
      expected = dynamic([q], is_nil(q.location))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for nil field with :last binding" do
      result = GtLtEq.field_is_nil_dynamic(:location)
      expected = dynamic([q], is_nil(q.location))
      assert inspect(result) == inspect(expected)
    end
  end

  describe "gt_dynamic/4" do
    test "builds a dynamic query for greater than with :and logic" do
      result = GtLtEq.gt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years > ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for greater than with :or logic" do
      result = GtLtEq.gt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years > ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for greater than with :last binding" do
      result = GtLtEq.gt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years > ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "gte_dynamic/4" do
    test "builds a dynamic query for greater than or equal with :and logic" do
      result = GtLtEq.gte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years >= ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for greater than or equal with :or logic" do
      result = GtLtEq.gte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years >= ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for greater than or equal with :last binding" do
      result = GtLtEq.gte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years >= ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "lt_dynamic/4" do
    test "builds a dynamic query for less than with :and logic" do
      result = GtLtEq.lt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years < ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for less than with :or logic" do
      result = GtLtEq.lt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years < ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for less than with :last binding" do
      result = GtLtEq.lt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years < ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "lte_dynamic/4" do
    test "builds a dynamic query for less than or equal with :and logic" do
      result = GtLtEq.lte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years <= ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for less than or equal with :or logic" do
      result = GtLtEq.lte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years <= ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for less than or equal with :last binding" do
      result = GtLtEq.lte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years <= ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "eq_dynamic/4" do
    test "builds a dynamic query for equality with :and logic" do
      result = GtLtEq.eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years == ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for equality with :or logic" do
      result = GtLtEq.eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years == ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for equality with :last binding" do
      result = GtLtEq.eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years == ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic cast_to_date_eq_dynamic for equality" do
      result = GtLtEq.cast_to_date_eq_dynamic(:end_date, ~D[2025-02-08])
      expected = dynamic([q], fragment("?::date", q.end_date) == ^~D[2025-02-08])
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic cast_to_date_eq_dynamic for equality with string date" do
      string_date = "2022-01-06"
      result = GtLtEq.cast_to_date_eq_dynamic(:end_date, string_date)
      expected = dynamic([q], fragment("?::date", q.end_date) == ^"2022-01-06")
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic cast_to_date_gt_dynamic for equality" do
      result = GtLtEq.cast_to_date_gt_dynamic(:end_date, ~D[2025-02-08])
      expected = dynamic([q], fragment("?::date", q.end_date) > ^~D[2025-02-08])
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic cast_to_date_gte_dynamic for equality" do
      result = GtLtEq.cast_to_date_gte_dynamic(:end_date, ~D[2025-02-08])
      expected = dynamic([q], fragment("?::date", q.end_date) >= ^~D[2025-02-08])
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic cast_to_date_lt_dynamic for equality" do
      result = GtLtEq.cast_to_date_lt_dynamic(:end_date, ~D[2025-02-08])
      expected = dynamic([q], fragment("?::date", q.end_date) < ^~D[2025-02-08])
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic cast_to_date_lte_dynamic for equality" do
      result = GtLtEq.cast_to_date_lte_dynamic(:end_date, ~D[2025-02-08])
      expected = dynamic([q], fragment("?::date", q.end_date) <= ^~D[2025-02-08])
      assert inspect(result) == inspect(expected)
    end
  end

  describe "not_eq_dynamic/4" do
    test "builds a dynamic query for inequality with :and logic" do
      result = GtLtEq.not_eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years != ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for inequality with :or logic" do
      result = GtLtEq.not_eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years != ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for inequality with :last binding" do
      result = GtLtEq.not_eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years != ^2)
      assert inspect(result) == inspect(expected)
    end
  end
end
