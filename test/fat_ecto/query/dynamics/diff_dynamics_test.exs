defmodule FatEcto.Dynamics.FatDynamicsTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  alias FatEcto.Query.Dynamics.BtwInContains
  alias FatEcto.Query.Dynamics.GtLtEq
  alias FatEcto.Query.Dynamics.Like

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

  describe "between_dynamic/4" do
    test "builds a dynamic query for between range with :and logic" do
      result = BtwInContains.between_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for between range with :or logic" do
      result = BtwInContains.between_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for between range with :last binding" do
      result =
        BtwInContains.between_dynamic(:experience_years, [2, 5])

      expected = dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "between_equal_dynamic/4" do
    test "builds a dynamic query for between or equal range with :and logic" do
      result = BtwInContains.between_equal_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for between or equal range with :or logic" do
      result = BtwInContains.between_equal_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for between or equal range with :last binding" do
      result =
        BtwInContains.between_equal_dynamic(:experience_years, [2, 5])

      expected = dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "in_dynamic/4" do
    test "builds a dynamic query for in list with :and logic" do
      result = BtwInContains.in_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years in ^[2, 5])
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for in list with :or logic" do
      result = BtwInContains.in_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years in ^[2, 5])
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for in list with :last binding" do
      result = BtwInContains.in_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years in ^[2, 5])
      assert inspect(result) == inspect(expected)
    end
  end

  describe "contains_dynamic/4" do
    test "builds a dynamic query for JSONB containment with :and logic" do
      result = BtwInContains.contains_dynamic(:metadata, %{"role" => "admin"})
      expected = dynamic([q], fragment("? @> ?", q.metadata, ^%{"role" => "admin"}))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for JSONB containment with :or logic" do
      result = BtwInContains.contains_dynamic(:metadata, %{"role" => "admin"})
      expected = dynamic([q], fragment("? @> ?", q.metadata, ^%{"role" => "admin"}))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for JSONB containment with :last binding" do
      result =
        BtwInContains.contains_dynamic(:metadata, %{"role" => "admin"})

      expected = dynamic([q], fragment("? @> ?", q.metadata, ^%{"role" => "admin"}))
      assert inspect(result) == inspect(expected)
    end
  end

  describe "contains_any_dynamic/4" do
    test "builds a dynamic query for JSONB overlap with :and logic" do
      result = BtwInContains.contains_any_dynamic(:tags, ["elixir", "erlang"])
      expected = dynamic([q], fragment("? && ?", q.tags, ^["elixir", "erlang"]))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for JSONB overlap with :or logic" do
      result = BtwInContains.contains_any_dynamic(:tags, ["elixir", "erlang"])
      expected = dynamic([q], fragment("? && ?", q.tags, ^["elixir", "erlang"]))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for JSONB overlap with :last binding" do
      result =
        BtwInContains.contains_any_dynamic(:tags, ["elixir", "erlang"])

      expected = dynamic([q], fragment("? && ?", q.tags, ^["elixir", "erlang"]))
      assert inspect(result) == inspect(expected)
    end
  end

  describe "FatEcto.Query.Dynamics.Like" do
    alias FatEcto.Query.Dynamics.Like

    test "ilike_dynamic/2 builds a case-insensitive LIKE dynamic" do
      result = Like.ilike_dynamic(:name, "%john%")
      expected = dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^"%john%"))
      assert inspect(result) == inspect(expected)
    end

    test "array_ilike_dynamic/2 builds a dynamic for array field ilike" do
      result = Like.array_ilike_dynamic(:tags, "%elixir%")

      expected =
        dynamic(
          [q],
          fragment("EXISTS (SELECT 1 FROM UNNEST(?) as value WHERE value ILIKE ?)", q.tags, ^"%elixir%")
        )

      assert inspect(result) == inspect(expected)
    end

    test "like_dynamic/2 builds a case-sensitive LIKE dynamic" do
      result = Like.like_dynamic(:name, "%John%")
      expected = dynamic([q], like(fragment("(?)::TEXT", q.name), ^"%John%"))
      assert inspect(result) == inspect(expected)
    end

    test "not_ilike_dynamic/2 builds a NOT ILIKE dynamic" do
      result = Like.not_ilike_dynamic(:name, "%john%")
      expected = dynamic([q], not ilike(fragment("(?)::TEXT", q.name), ^"%john%"))
      assert inspect(result) == inspect(expected)
    end

    test "not_like_dynamic/2 builds a NOT LIKE dynamic" do
      result = Like.not_like_dynamic(:name, "%John%")
      expected = dynamic([q], not like(fragment("(?)::TEXT", q.name), ^"%John%"))
      assert inspect(result) == inspect(expected)
    end
  end
end
