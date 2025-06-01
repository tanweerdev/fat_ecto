defmodule FatEcto.Query.HospitalQueryBuilderTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatHospital

  alias FatEcto.Query.HospitalQueryBuilder

  describe "build/3" do
    test "filters by name with custom $ILIKE operator" do
      base_query = from(h in FatHospital)
      query = HospitalQueryBuilder.build(base_query, %{"name" => %{"$ILIKE" => "%General%"}})

      expected_query = from(h in FatHospital, where: ilike(fragment("(?)::TEXT", h.name), ^"%General%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by name with custom $LIKE operator" do
      base_query = from(h in FatHospital)
      query = HospitalQueryBuilder.build(base_query, %{"name" => %{"$LIKE" => "%General%"}})

      expected_query = from(h in FatHospital, where: like(fragment("(?)::TEXT", h.name), ^"%General%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores name with ignoreable value" do
      base_query = from(h in FatHospital)
      query = HospitalQueryBuilder.build(base_query, %{"name" => ""})

      assert query == base_query
    end

    test "filters by phone with custom $ILIKE operator" do
      base_query = from(h in FatHospital)
      query = HospitalQueryBuilder.build(base_query, %{"phone" => %{"$ILIKE" => "%123%"}})

      expected_query = from(h in FatHospital, where: ilike(fragment("(?)::TEXT", h.phone), ^"%123%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores phone with ignoreable value" do
      base_query = from(h in FatHospital)
      query = HospitalQueryBuilder.build(base_query, %{"phone" => nil})

      assert query == base_query
    end

    test "does not filter by non-overrideable fields" do
      base_query = from(h in FatHospital)
      query = HospitalQueryBuilder.build(base_query, %{"email" => "test@example.com"})

      assert query == base_query
    end
  end
end
