defmodule FatEcto.Query.MyApp.RoomQueryTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatRoom

  alias FatEcto.Query.MyApp.RoomQuery

  describe "build/3" do
    test "filters by name with custom $LIKE operator" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"name" => %{"$LIKE" => "%ICU%"}})

      expected_query = from(r in FatRoom, where: like(fragment("(?)::TEXT", r.name), ^"%ICU%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by name with custom $ILIKE operator" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"name" => %{"$ILIKE" => "%ICU%"}})

      expected_query = from(r in FatRoom, where: ilike(fragment("(?)::TEXT", r.name), ^"%ICU%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores name with ignoreable value" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"name" => "%%"})

      assert query == base_query
    end

    test "filters by phone with custom $ILIKE operator" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"phone" => %{"$ILIKE" => "%123%"}})

      expected_query = from(r in FatRoom, where: ilike(fragment("(?)::TEXT", r.phone), ^"%123%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores phone with ignoreable value" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"phone" => "%%"})

      assert query == base_query
    end

    test "filters by purpose with $IN operator" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"purpose" => %{"$IN" => ["Surgery", "ICU"]}})

      expected_query = from(r in FatRoom, where: r.purpose in ^["Surgery", "ICU"])
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores purpose with empty list value" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"purpose" => []})

      assert query == base_query
    end

    test "ignores purpose with empty $IN list" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"purpose" => %{"$IN" => []}})

      assert query == base_query
    end

    test "filters by description with $EQUAL operator" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"description" => "Private Room"})

      expected_query = from(r in FatRoom, where: r.description == ^"Private Room")
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores description with nil value" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"description" => nil})

      assert query == base_query
    end

    test "ignores description with nil $EQUAL value" do
      base_query = from(r in FatRoom)
      query = RoomQuery.build(base_query, %{"description" => %{"$EQUAL" => nil}})

      assert query == base_query
    end
  end
end
