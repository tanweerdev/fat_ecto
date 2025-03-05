defmodule FatEcto.Dynamics.MyApp.HospitalFilterTest do
  use FatEcto.ConnCase
  import Ecto.Query

  describe "build/2" do
    test "filters by name with custom $ILIKE operator" do
      dynamics = HospitalFilter.build(%{"name" => %{"$ILIKE" => "%General%"}})

      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^"%General%"))

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by name with custom $LIKE operator" do
      dynamics = HospitalFilter.build(%{"name" => %{"$LIKE" => "%General%"}})

      expected_dynamics = dynamic([q], like(fragment("(?)::TEXT", q.name), ^"%General%"))

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores name with ignoreable value" do
      dynamics = HospitalFilter.build(%{"name" => ""})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by phone with custom $ILIKE operator" do
      dynamics = HospitalFilter.build(%{"phone" => %{"$ILIKE" => "%123%"}})
      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^"%123%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores phone with ignoreable value" do
      dynamics = HospitalFilter.build(%{"phone" => nil})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "does not filter by non-overrideable fields" do
      dynamics = HospitalFilter.build(%{"email" => "test@example.com"})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end
  end
end
