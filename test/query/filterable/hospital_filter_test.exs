defmodule FatEcto.FatHospitalFilterTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatHospitalFilter

  describe "build/2" do
    test "filters by name with custom $ILIKE operator" do
      query = FatHospitalFilter.build(%{"name" => %{"$ILIKE" => "%General%"}})

      expected_query = dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^"%General%"))

      assert inspect(query) == inspect(expected_query)
    end

    @tag :dev
    test "filters by name with custom $LIKE operator" do
      query = FatHospitalFilter.build(%{"name" => %{"$LIKE" => "%General%"}})

      expected_query = dynamic([q], like(fragment("(?)::TEXT", q.name), ^"%General%"))

      assert inspect(query) == inspect(expected_query)
    end

    test "ignores name with ignoreable value" do
      query = FatHospitalFilter.build(%{"name" => ""})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by phone with custom $ILIKE operator" do
      query = FatHospitalFilter.build(%{"phone" => %{"$ILIKE" => "%123%"}})
      expected_query = dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^"%123%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores phone with ignoreable value" do
      query = FatHospitalFilter.build(%{"phone" => nil})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end

    test "does not filter by non-overrideable fields" do
      query = FatHospitalFilter.build(%{"email" => "test@example.com"})
      expected_query = nil
      assert inspect(query) == inspect(expected_query)
    end
  end
end
