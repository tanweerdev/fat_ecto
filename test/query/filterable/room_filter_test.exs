defmodule RoomFilterTest do
  use FatEcto.ConnCase

  describe "RoomFilter" do
    test "returns the query where field like" do
      opts = %{"name" => %{"$like" => "%Room 1%"}}
      expected = from(r in FatEcto.FatRoom, where: like(fragment("(?)::TEXT", r.name), ^"%Room 1%"))
      query = RoomFilter.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query where field ilike is built with override_whereable" do
      opts = %{"name" => %{"$ilike" => "%room 1%"}}

      expected =
        from(r in FatEcto.FatRoom, where: ilike(fragment("(?)::TEXT", r.name), ^"%room 1%"))

      query = RoomFilter.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end

    test "applies custom override for phone field" do
      opts = %{"phone" => %{"$ilike" => "%123%"}}
      expected = from(r in FatEcto.FatRoom, where: ilike(fragment("(?)::TEXT", r.phone), ^"%123%"))
      query = RoomFilter.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignores empty list in where params" do
      opts = %{"purpose" => %{"$in" => []}}
      expected = from(r in FatEcto.FatRoom)
      query = RoomFilter.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end
  end
end
