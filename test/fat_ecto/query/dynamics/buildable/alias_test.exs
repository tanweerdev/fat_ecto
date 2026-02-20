defmodule FatEcto.Query.Dynamics.AliasTest do
  @moduledoc false

  use FatEcto.ConnCase
  import Ecto.Query
  alias Ecto.Adapters.SQL
  alias FatEcto.FatHospital
  alias FatEcto.HospitalAliasDynamicsBuilder

  defp base_query do
    FatHospital
    |> join(:left, [h], r in assoc(h, :fat_rooms), as: :fat_rooms)
    |> join(:left, [h], d in assoc(h, :fat_doctors), as: :fat_doctors)
  end

  defp query_to_sql(dynamic) do
    base_query()
    |> where(^dynamic)
    |> inspect_query()
  end

  defp expected_to_sql(expected_dynamic) do
    base_query()
    |> where(^expected_dynamic)
    |> inspect_query()
  end

  defp inspect_query(query) do
    {sql, _params} = SQL.to_sql(:all, FatEcto.Repo, query)
    sql
  end

  describe "direct alias (main table)" do
    test "aliased field with $ILIKE resolves to correct schema field" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "hospital_location" => %{"$ILIKE" => "%city%"}
        })

      expected =
        dynamic([h], ilike(fragment("(?)::TEXT", h.location), ^"%city%"))

      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "aliased field with $EQUAL resolves to correct schema field" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "hospital_location" => %{"$EQUAL" => "New York"}
        })

      expected = dynamic([h], h.location == ^"New York")
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "aliased field with direct value (no operator map)" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "hospital_location" => "Boston"
        })

      expected = dynamic([h], h.location == ^"Boston")
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "aliased and non-aliased direct fields work together" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "hospital_location" => %{"$EQUAL" => "Chicago"},
          "total_staff" => %{"$GTE" => 10}
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "\"location\" = $"
      assert sql =~ "\"total_staff\" >= $"
    end
  end

  describe "join alias (joined tables)" do
    test "aliased join field with $ILIKE resolves to correct schema field" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "room_name" => %{"$ILIKE" => "%ICU%"}
        })

      expected =
        dynamic(
          [fat_rooms: r],
          ilike(fragment("(?)::TEXT", r.name), ^"%ICU%")
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "aliased join field with $EQUAL resolves to correct schema field" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "doctor_name" => %{"$EQUAL" => "Dr. Smith"}
        })

      expected = dynamic([fat_doctors: d], d.name == ^"Dr. Smith")
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "aliased join field with numeric comparison" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "doctor_rating" => %{"$GTE" => 4}
        })

      expected = dynamic([fat_doctors: d], d.rating >= ^4)
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "non-aliased join field still works" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "floor" => %{"$EQUAL" => 3}
        })

      expected = dynamic([fat_rooms: r], r.floor == ^3)
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "aliased and non-aliased join fields from same binding" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "room_name" => %{"$EQUAL" => "ICU"},
          "floor" => %{"$GTE" => 2}
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f1.\"name\" = $"
      assert sql =~ "f1.\"floor\" >= $"
    end
  end

  describe "field name conflict resolution" do
    test "main table name and room name filtered independently" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "name" => %{"$EQUAL" => "General Hospital"},
          "room_name" => %{"$EQUAL" => "ICU"}
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f0.\"name\" = $"
      assert sql =~ "f1.\"name\" = $"
    end

    test "main table name and doctor name filtered independently" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "name" => %{"$EQUAL" => "City Hospital"},
          "doctor_name" => %{"$EQUAL" => "Dr. Smith"}
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f0.\"name\" = $"
      assert sql =~ "f2.\"name\" = $"
    end

    test "all three name fields filtered simultaneously" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "name" => %{"$EQUAL" => "Hospital"},
          "room_name" => %{"$EQUAL" => "ER"},
          "doctor_name" => %{"$EQUAL" => "Johnson"}
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f0.\"name\" = $"
      assert sql =~ "f1.\"name\" = $"
      assert sql =~ "f2.\"name\" = $"
    end

    test "hospital rating vs doctor rating resolved independently" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "doctor_rating" => %{"$GTE" => 4, "$LTE" => 5}
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f2.\"rating\" >= $"
      assert sql =~ "f2.\"rating\" <= $"
    end
  end

  describe "$OR with aliases" do
    test "aliased fields inside $OR" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "$OR" => [
            %{"room_name" => %{"$EQUAL" => "ICU"}},
            %{"room_name" => %{"$EQUAL" => "ER"}}
          ]
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f1.\"name\" = $"
      assert sql =~ " OR "
    end

    test "mixed aliased and non-aliased fields in $OR" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "$OR" => [
            %{"name" => %{"$EQUAL" => "General"}},
            %{"room_name" => %{"$EQUAL" => "ER"}}
          ]
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f0.\"name\" = $"
      assert sql =~ "f1.\"name\" = $"
      assert sql =~ " OR "
    end

    test "aliased fields in $OR combined with top-level filter" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "total_staff" => %{"$GTE" => 10},
          "$OR" => [
            %{"doctor_name" => %{"$EQUAL" => "Smith"}},
            %{"doctor_rating" => %{"$GTE" => 4}}
          ]
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "\"total_staff\" >= $"
      assert sql =~ "f2.\"name\" = $"
      assert sql =~ "f2.\"rating\" >= $"
      assert sql =~ " OR "
      assert sql =~ " AND "
    end
  end

  describe "$AND with aliases" do
    test "aliased fields inside $AND" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "$AND" => [
            %{"doctor_name" => %{"$EQUAL" => "Dr. Smith"}},
            %{"doctor_rating" => %{"$GTE" => 3}}
          ]
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f2.\"name\" = $"
      assert sql =~ "f2.\"rating\" >= $"
      assert sql =~ " AND "
    end
  end

  describe "overrideable fields alongside aliases" do
    test "overrideable field works alongside aliased filters" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "search" => %{"$ILIKE" => "cardio"},
          "doctor_name" => %{"$EQUAL" => "Dr. Heart"}
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f0.\"name\""
      assert sql =~ "f0.\"location\""
      assert sql =~ "f2.\"name\" = $"
    end
  end

  describe "ignoreable fields with aliases" do
    test "ignoreable uses API name (non-aliased field)" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "name" => %{"$ILIKE" => "%%"}
        })

      expected = dynamic([q], true)
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "non-ignoreable aliased field still filters" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "hospital_location" => %{"$EQUAL" => "downtown"}
        })

      expected = dynamic([h], h.location == ^"downtown")
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end
  end

  describe "backward compatibility (no aliases)" do
    test "non-aliased field works with $EQUAL" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "total_staff" => %{"$GTE" => 5}
        })

      expected = dynamic([h], h.total_staff >= ^5)
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "empty params returns default dynamic" do
      dynamics = HospitalAliasDynamicsBuilder.build(%{})
      expected = dynamic([q], true)
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "unknown fields are dropped" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "nonexistent" => %{"$EQUAL" => "value"}
        })

      expected = dynamic([q], true)
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end

    test "original schema field name cannot be used when alias is defined" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "location" => %{"$ILIKE" => "%test%"}
        })

      expected = dynamic([q], true)
      assert query_to_sql(dynamics) == expected_to_sql(expected)
    end
  end

  describe "complex combined scenarios" do
    test "all filter types combined" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "name" => %{"$EQUAL" => "Metro Hospital"},
          "hospital_location" => %{"$EQUAL" => "downtown"},
          "floor" => %{"$EQUAL" => 5},
          "room_name" => %{"$EQUAL" => "Suite A"},
          "doctor_rating" => %{"$GTE" => 4},
          "$OR" => [
            %{"doctor_name" => %{"$EQUAL" => "Smith"}},
            %{"experience_years" => %{"$GTE" => 10}}
          ]
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "WHERE"
      assert sql =~ "f0.\"name\" = $"
      assert sql =~ "f0.\"location\" = $"
      assert sql =~ "f1.\"floor\" = $"
      assert sql =~ "f1.\"name\" = $"
      assert sql =~ "f2.\"rating\" >= $"
      assert sql =~ " OR "
    end

    test "multiple aliased fields from different joins" do
      dynamics =
        HospitalAliasDynamicsBuilder.build(%{
          "room_name" => %{"$EQUAL" => "ER"},
          "doctor_name" => %{"$EQUAL" => "Smith"},
          "doctor_rating" => %{"$GTE" => 3}
        })

      sql = query_to_sql(dynamics)
      assert sql =~ "f1.\"name\" = $"
      assert sql =~ "f2.\"name\" = $"
      assert sql =~ "f2.\"rating\" >= $"
    end
  end
end
