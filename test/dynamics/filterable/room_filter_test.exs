defmodule FatEcto.FatRoomTest do
  use FatEcto.ConnCase
  import Ecto.Query

  describe "build/2" do
    test "filters by name with custom $LIKE operator" do
      query = RoomFilter.build(%{"name" => %{"$LIKE" => "%ICU%"}})
      expected_query = dynamic([q], like(fragment("(?)::TEXT", q.name), ^"%ICU%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by name with custom $ILIKE operator" do
      query = RoomFilter.build(%{"name" => %{"$ILIKE" => "%ICU%"}})
      expected_query = dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^"%ICU%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores name with ignoreable value" do
      query = RoomFilter.build(%{"name" => "%%"})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by phone with custom $ILIKE operator" do
      query = RoomFilter.build(%{"phone" => %{"$ILIKE" => "%123%"}})
      expected_query = dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^"%123%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores phone with ignoreable value" do
      query = RoomFilter.build(%{"phone" => "%%"})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by purpose with $IN operator" do
      query = RoomFilter.build(%{"purpose" => %{"$IN" => ["Surgery", "ICU"]}})
      expected_query = dynamic([q], q.purpose in ^["Surgery", "ICU"])
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores purpose with ignoreable value" do
      query = RoomFilter.build(%{"purpose" => []})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by description with $EQUAL operator" do
      query = RoomFilter.build(%{"description" => "Private Room"})
      expected_query = dynamic([q], q.description == ^"Private Room")
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores description with ignoreable value" do
      query = RoomFilter.build(%{"description" => nil})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end
  end
end
