defmodule FatEcto.FatRoomTest do
  use FatEcto.ConnCase
  import Ecto.Query

  describe "build/2" do
    test "filters by name with custom $LIKE operator" do
      dynamics = RoomFilter.build(%{"name" => %{"$LIKE" => "%ICU%"}})
      expected_dynamics = dynamic([q], like(fragment("(?)::TEXT", q.name), ^"%ICU%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by name with custom $ILIKE operator" do
      dynamics = RoomFilter.build(%{"name" => %{"$ILIKE" => "%ICU%"}})
      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^"%ICU%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores name with ignoreable value" do
      dynamics = RoomFilter.build(%{"name" => "%%"})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by phone with custom $ILIKE operator" do
      dynamics = RoomFilter.build(%{"phone" => %{"$ILIKE" => "%123%"}})
      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^"%123%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores phone with ignoreable value" do
      dynamics = RoomFilter.build(%{"phone" => "%%"})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by purpose with $IN operator" do
      dynamics = RoomFilter.build(%{"purpose" => %{"$IN" => ["Surgery", "ICU"]}})
      expected_dynamics = dynamic([q], q.purpose in ^["Surgery", "ICU"])
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores purpose with ignoreable value" do
      dynamics = RoomFilter.build(%{"purpose" => []})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    @tag :dev
    test "filters by description with $EQUAL operator" do
      dynamics = RoomFilter.build(%{"description" => "Private Room"})
      expected_dynamics = dynamic([q], q.description == ^"Private Room")
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores description with ignoreable value" do
      dynamics = RoomFilter.build(%{"description" => nil})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end
  end
end
