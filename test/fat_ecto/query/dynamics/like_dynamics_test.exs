defmodule FatEcto.Query.Dynamics.LikeTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  alias FatEcto.Query.Dynamics.Like

  describe "FatEcto.Query.Dynamics.Like" do
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
