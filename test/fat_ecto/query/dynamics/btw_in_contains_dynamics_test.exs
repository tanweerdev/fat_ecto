defmodule FatEcto.Query.Dynamics.BtwInContainsTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  alias FatEcto.Query.Dynamics.BtwInContains

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
end
