defmodule FatDoctor.FilterTest do
  use FatEcto.ConnCase
  import Ecto.Query

  describe "build/2" do
    test "filters by email with $EQUAL operator" do
      query = DoctorFilter.build(%{"email" => "test@example.com"})
      expected_query = dynamic([q], q.email == ^"test@example.com")
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by email with $ILIKE operator" do
      query = DoctorFilter.build(%{"email" => %{"$ILIKE" => "%test%"}})
      expected_query = dynamic([q], ilike(fragment("(?)::TEXT", q.email), ^"%test%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores email with ignoreable value" do
      query = DoctorFilter.build(%{"email" => ""})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by name with direct comparison" do
      query = DoctorFilter.build(%{"name" => "John"})
      expected_query = dynamic([q], q.name == ^"John")
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by name with $LIKE operator" do
      query = DoctorFilter.build(%{"name" => %{"$LIKE" => "%John%"}})
      expected_query = dynamic([q], like(fragment("(?)::TEXT", q.name), ^"%John%"))
      assert inspect(query) == inspect(expected_query)
    end

    @tag :dev
    test "filters by phone with custom $ILIKE operator" do
      query = DoctorFilter.build(%{"phone" => %{"$ILIKE" => "%123%"}})
      expected_query = dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^"%123%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores phone with ignoreable value" do
      query = DoctorFilter.build(%{"phone" => nil})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by rating with $GT operator" do
      query = DoctorFilter.build(%{"rating" => %{"$GT" => 4}})
      expected_query = dynamic([q], q.rating > ^4)
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by start_date with $GTE operator" do
      query = DoctorFilter.build(%{"start_date" => %{"$GTE" => "2023-01-01"}})
      expected_query = dynamic([q], q.start_date >= ^"2023-01-01")
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by location with $IN operator" do
      query = DoctorFilter.build(%{"location" => %{"$IN" => ["New York", "London"]}})
      expected_query = dynamic([q], q.location in ^["New York", "London"])
      assert inspect(query) == inspect(expected_query)
    end
  end
end
