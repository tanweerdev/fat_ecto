defmodule FatDoctor.FilterTest do
  use FatEcto.ConnCase
  import Ecto.Query

  describe "build/2" do
    test "filters by email with $EQUAL operator" do
      dynamics = DoctorFilter.build(%{"email" => "test@example.com"})
      expected_dynamics = dynamic([q], q.email == ^"test@example.com")
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by email with $ILIKE operator" do
      dynamics = DoctorFilter.build(%{"email" => %{"$ILIKE" => "%test%"}})
      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.email), ^"%test%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores email with ignoreable value" do
      dynamics = DoctorFilter.build(%{"email" => ""})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by name with direct comparison" do
      dynamics = DoctorFilter.build(%{"name" => "John"})
      expected_dynamics = dynamic([q], q.name == ^"John")
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by name with $LIKE operator" do
      dynamics = DoctorFilter.build(%{"name" => %{"$LIKE" => "%John%"}})
      expected_dynamics = dynamic([q], like(fragment("(?)::TEXT", q.name), ^"%John%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by phone with custom $ILIKE operator" do
      dynamics = DoctorFilter.build(%{"phone" => %{"$ILIKE" => "%123%"}})
      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^"%123%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores phone with ignoreable value" do
      dynamics = DoctorFilter.build(%{"phone" => nil})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by rating with $GT operator" do
      dynamics = DoctorFilter.build(%{"rating" => %{"$GT" => 4}})
      expected_dynamics = dynamic([q], q.rating > ^4)
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by start_date with $GTE operator" do
      dynamics = DoctorFilter.build(%{"start_date" => %{"$GTE" => "2023-01-01"}})
      expected_dynamics = dynamic([q], q.start_date >= ^"2023-01-01")
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by location with $IN operator" do
      dynamics = DoctorFilter.build(%{"location" => %{"$IN" => ["New York", "London"]}})
      expected_dynamics = dynamic([q], q.location in ^["New York", "London"])
      assert inspect(dynamics) == inspect(expected_dynamics)
    end
  end
end
