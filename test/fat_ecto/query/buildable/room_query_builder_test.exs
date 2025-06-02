defmodule FatEcto.Query.RoomQueryBuilderTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatRoom

  alias FatEcto.Query.RoomQueryBuilder

  describe "build/3" do
    test "filters by name with custom $LIKE operator" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"name" => %{"$LIKE" => "%ICU%"}})

      expected_query = from(r in FatRoom, where: like(fragment("(?)::TEXT", r.name), ^"%ICU%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "override_buildable is properly called for overrideable fields" do
      base_query = from(r in FatRoom)

      # This will call our override_buildable function
      query = RoomQueryBuilder.build(base_query, %{"name" => %{"$LIKE" => "%ICU%"}})

      # Verify the query was modified by our override
      assert inspect(query) =~ "like(fragment(\"(?)::TEXT\", f0.name), ^\"%ICU%\")"

      # Verify the base query wasn't modified directly
      refute inspect(base_query) =~ "like(fragment"
    end

    test "filters by name with custom $ILIKE operator" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"name" => %{"$ILIKE" => "%ICU%"}})

      expected_query = from(r in FatRoom, where: ilike(fragment("(?)::TEXT", r.name), ^"%ICU%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores name with ignoreable value" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"name" => "%%"})

      assert query == base_query
    end

    test "filters by phone with custom $ILIKE operator" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"phone" => %{"$ILIKE" => "%123%"}})

      expected_query = from(r in FatRoom, where: ilike(fragment("(?)::TEXT", r.phone), ^"%123%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores phone with ignoreable value" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"phone" => "%%"})

      assert query == base_query
    end

    test "filters by purpose with $IN operator" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"purpose" => %{"$IN" => ["Surgery", "ICU"]}})

      expected_query = from(r in FatRoom, where: r.purpose in ^["Surgery", "ICU"])
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores purpose with empty list value" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"purpose" => []})

      assert query == base_query
    end

    test "ignores purpose with empty $IN list" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"purpose" => %{"$IN" => []}})

      assert query == base_query
    end

    test "filters by description with $EQUAL operator" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"description" => "Private Room"})

      expected_query = from(r in FatRoom, where: r.description == ^"Private Room")
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores description with nil value" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"description" => nil})

      assert query == base_query
    end

    test "ignores description with nil $EQUAL value" do
      base_query = from(r in FatRoom)
      query = RoomQueryBuilder.build(base_query, %{"description" => %{"$EQUAL" => nil}})

      assert query == base_query
    end
  end
end
