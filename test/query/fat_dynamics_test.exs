defmodule FatEcto.FatQuery.FatDynamicsTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  alias FatEcto.FatQuery.FatDynamics

  describe "field_is_nil_dynamic/3" do
    test "builds a dynamic query for nil field with :and logic" do
      result = FatDynamics.field_is_nil_dynamic(:location)
      expected = dynamic([c], is_nil(c.location))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for nil field with :or logic" do
      result = FatDynamics.field_is_nil_dynamic(:location)
      expected = dynamic([c], is_nil(c.location))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for nil field with :last binding" do
      result = FatDynamics.field_is_nil_dynamic(:location, binding: :last)
      expected = dynamic([_, ..., c], is_nil(c.location))
      assert inspect(result) == inspect(expected)
    end
  end

  describe "gt_dynamic/4" do
    test "builds a dynamic query for greater than with :and logic" do
      result = FatDynamics.gt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years > ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for greater than with :or logic" do
      result = FatDynamics.gt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years > ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for greater than with :last binding" do
      result = FatDynamics.gt_dynamic(:experience_years, 2, binding: :last)
      expected = dynamic([_, ..., c], c.experience_years > ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "gte_dynamic/4" do
    test "builds a dynamic query for greater than or equal with :and logic" do
      result = FatDynamics.gte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years >= ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for greater than or equal with :or logic" do
      result = FatDynamics.gte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years >= ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for greater than or equal with :last binding" do
      result = FatDynamics.gte_dynamic(:experience_years, 2, binding: :last)
      expected = dynamic([_, ..., c], c.experience_years >= ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "lt_dynamic/4" do
    test "builds a dynamic query for less than with :and logic" do
      result = FatDynamics.lt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years < ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for less than with :or logic" do
      result = FatDynamics.lt_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years < ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for less than with :last binding" do
      result = FatDynamics.lt_dynamic(:experience_years, 2, binding: :last)
      expected = dynamic([_, ..., c], c.experience_years < ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "lte_dynamic/4" do
    test "builds a dynamic query for less than or equal with :and logic" do
      result = FatDynamics.lte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years <= ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for less than or equal with :or logic" do
      result = FatDynamics.lte_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years <= ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for less than or equal with :last binding" do
      result = FatDynamics.lte_dynamic(:experience_years, 2, binding: :last)
      expected = dynamic([c], c.experience_years <= ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "eq_dynamic/4" do
    test "builds a dynamic query for equality with :and logic" do
      result = FatDynamics.eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years == ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for equality with :or logic" do
      result = FatDynamics.eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years == ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for equality with :last binding" do
      result = FatDynamics.eq_dynamic(:experience_years, 2, binding: :last)
      expected = dynamic([_, ..., c], c.experience_years == ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "not_eq_dynamic/4" do
    test "builds a dynamic query for inequality with :and logic" do
      result = FatDynamics.not_eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years != ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for inequality with :or logic" do
      result = FatDynamics.not_eq_dynamic(:experience_years, 2)
      expected = dynamic([q], q.experience_years != ^2)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for inequality with :last binding" do
      result = FatDynamics.not_eq_dynamic(:experience_years, 2, binding: :last)
      expected = dynamic([_, ..., c], c.experience_years != ^2)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "between_dynamic/4" do
    test "builds a dynamic query for between range with :and logic" do
      result = FatDynamics.between_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for between range with :or logic" do
      result = FatDynamics.between_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for between range with :last binding" do
      result =
        FatDynamics.between_dynamic(:experience_years, [2, 5], binding: :last)

      expected = dynamic([_, ..., c], c.experience_years > ^2 and c.experience_years < ^5)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "between_equal_dynamic/4" do
    test "builds a dynamic query for between or equal range with :and logic" do
      result = FatDynamics.between_equal_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for between or equal range with :or logic" do
      result = FatDynamics.between_equal_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5)
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for between or equal range with :last binding" do
      result =
        FatDynamics.between_equal_dynamic(:experience_years, [2, 5], binding: :last)

      expected = dynamic([_, ..., c], c.experience_years >= ^2 and c.experience_years <= ^5)
      assert inspect(result) == inspect(expected)
    end
  end

  describe "in_dynamic/4" do
    test "builds a dynamic query for in list with :and logic" do
      result = FatDynamics.in_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years in ^[2, 5])
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for in list with :or logic" do
      result = FatDynamics.in_dynamic(:experience_years, [2, 5])
      expected = dynamic([q], q.experience_years in ^[2, 5])
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for in list with :last binding" do
      result = FatDynamics.in_dynamic(:experience_years, [2, 5], binding: :last)
      expected = dynamic([_, ..., c], c.experience_years in ^[2, 5])
      assert inspect(result) == inspect(expected)
    end
  end

  describe "contains_dynamic/4" do
    test "builds a dynamic query for JSONB containment with :and logic" do
      result = FatDynamics.contains_dynamic(:metadata, %{"role" => "admin"})
      expected = dynamic([q], fragment("? @> ?", q.metadata, ^%{"role" => "admin"}))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for JSONB containment with :or logic" do
      result = FatDynamics.contains_dynamic(:metadata, %{"role" => "admin"})
      expected = dynamic([q], fragment("? @> ?", q.metadata, ^%{"role" => "admin"}))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for JSONB containment with :last binding" do
      result =
        FatDynamics.contains_dynamic(:metadata, %{"role" => "admin"}, binding: :last)

      expected = dynamic([_, ..., c], fragment("? @> ?", c.metadata, ^%{"role" => "admin"}))
      assert inspect(result) == inspect(expected)
    end
  end

  describe "contains_any_dynamic/4" do
    test "builds a dynamic query for JSONB overlap with :and logic" do
      result = FatDynamics.contains_any_dynamic(:tags, ["elixir", "erlang"])
      expected = dynamic([q], fragment("? && ?", q.tags, ^["elixir", "erlang"]))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for JSONB overlap with :or logic" do
      result = FatDynamics.contains_any_dynamic(:tags, ["elixir", "erlang"])
      expected = dynamic([q], fragment("? && ?", q.tags, ^["elixir", "erlang"]))
      assert inspect(result) == inspect(expected)
    end

    test "builds a dynamic query for JSONB overlap with :last binding" do
      result =
        FatDynamics.contains_any_dynamic(:tags, ["elixir", "erlang"], binding: :last)

      expected = dynamic([_, ..., c], fragment("? && ?", c.tags, ^["elixir", "erlang"]))
      assert inspect(result) == inspect(expected)
    end
  end
end
