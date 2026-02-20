defmodule FatEcto.Query.Dynamics.JoinFiltersTest do
  @moduledoc """
  Tests for join filter functionality in FatEcto.Query.Dynamics.Buildable.

  Join filters allow filtering on fields in related/joined tables using named bindings.
  The caller is responsible for providing the join with the correct `as:` binding.

  Uses existing FatEcto schemas:
  - FatHospital (main table)
  - FatRoom (joined via :fat_rooms binding)
  - FatDoctor (joined via :fat_doctors binding)
  """

  use FatEcto.ConnCase
  import Ecto.Query
  alias Ecto.Adapters.SQL
  alias FatEcto.FatHospital
  alias FatEcto.HospitalJoinDynamicsBuilder

  # Helper to build a base query with the proper joins for testing
  # This is needed because Ecto dynamics with named bindings can't be inspected
  # without a query that defines those bindings.
  defp base_query do
    FatHospital
    |> join(:left, [h], r in assoc(h, :fat_rooms), as: :fat_rooms)
    |> join(:left, [h], d in assoc(h, :fat_doctors), as: :fat_doctors)
  end

  # Helper to get SQL from a query with dynamic applied
  defp query_to_sql(dynamic) do
    base_query()
    |> where(^dynamic)
    |> inspect_query()
  end

  # Helper to get SQL from expected dynamic
  defp expected_to_sql(expected_dynamic) do
    base_query()
    |> where(^expected_dynamic)
    |> inspect_query()
  end

  # Extract just the WHERE clause for comparison
  defp inspect_query(query) do
    {sql, _params} = SQL.to_sql(:all, FatEcto.Repo, query)
    sql
  end

  describe "basic join filter" do
    test "filters by a single join filter field from rooms" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{"floor" => %{"$EQUAL" => 3}})

      expected_dynamics = dynamic([fat_rooms: j], j.floor == ^3)

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "filters by a join filter field from doctors" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{"experience_years" => %{"$GTE" => 5}})

      expected_dynamics = dynamic([fat_doctors: j], j.experience_years >= ^5)

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "filters with $IN operator on join filter field" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{"floor" => %{"$IN" => [1, 2, 3]}})

      expected_dynamics = dynamic([fat_rooms: j], j.floor in ^[1, 2, 3])

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "filters with $ILIKE operator on join filter field" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{"designation" => %{"$ILIKE" => "%surgeon%"}})

      expected_dynamics =
        dynamic([fat_doctors: j], ilike(fragment("(?)::TEXT", j.designation), ^"%surgeon%"))

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "filters with boolean on join filter field" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{"is_active" => %{"$EQUAL" => true}})

      expected_dynamics = dynamic([fat_rooms: j], j.is_active == ^true)

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "multiple join filters from same binding" do
    test "filters by multiple fields from fat_rooms binding" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "floor" => %{"$EQUAL" => 2},
          "is_active" => %{"$EQUAL" => true}
        })

      expected_dynamics =
        dynamic(
          [fat_rooms: j],
          j.floor == ^2 and j.is_active == ^true
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "filters by multiple fields from fat_doctors binding" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "experience_years" => %{"$GTE" => 5},
          "designation" => %{"$EQUAL" => "Surgeon"}
        })

      expected_dynamics =
        dynamic(
          [fat_doctors: j],
          j.designation == ^"Surgeon" and j.experience_years >= ^5
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "filters with range operators on same binding" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "floor" => %{"$GTE" => 1, "$LTE" => 5}
        })

      expected_dynamics =
        dynamic(
          [fat_rooms: j],
          j.floor >= ^1 and j.floor <= ^5
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "multiple join filters from different bindings" do
    test "filters by fields from both fat_rooms and fat_doctors" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "floor" => %{"$EQUAL" => 3},
          "experience_years" => %{"$GTE" => 10}
        })

      expected_dynamics =
        dynamic(
          [fat_rooms: j1, fat_doctors: j2],
          j2.experience_years >= ^10 and j1.floor == ^3
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "filters by multiple fields from multiple bindings" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "floor" => %{"$GTE" => 2},
          "is_active" => %{"$EQUAL" => true},
          "experience_years" => %{"$GTE" => 5},
          "designation" => %{"$IN" => ["Surgeon", "Physician"]}
        })

      expected_dynamics =
        dynamic(
          [fat_rooms: j1, fat_doctors: j2],
          j2.designation in ^["Surgeon", "Physician"] and j2.experience_years >= ^5 and
            j1.floor >= ^2 and j1.is_active == ^true
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "mix of direct filters and join filters" do
    test "combines direct filter with join filter" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "name" => %{"$ILIKE" => "%General%"},
          "floor" => %{"$EQUAL" => 1}
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j],
          j.floor == ^1 and ilike(fragment("(?)::TEXT", q.name), ^"%General%")
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "combines multiple direct filters with multiple join filters" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "name" => %{"$ILIKE" => "%Hospital%"},
          "rating" => %{"$GTE" => 4},
          "floor" => %{"$GTE" => 2},
          "experience_years" => %{"$GTE" => 10}
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j1, fat_doctors: j2],
          j2.experience_years >= ^10 and j1.floor >= ^2 and
            ilike(fragment("(?)::TEXT", q.name), ^"%Hospital%") and q.rating >= ^4
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "combines all filter types" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "name" => %{"$ILIKE" => "%City%"},
          "location" => %{"$EQUAL" => "Downtown"},
          "rating" => %{"$GTE" => 3, "$LTE" => 5},
          "floor" => %{"$IN" => [1, 2, 3]},
          "is_active" => %{"$EQUAL" => true},
          "designation" => %{"$ILIKE" => "%surgeon%"}
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j1, fat_doctors: j2],
          ilike(fragment("(?)::TEXT", j2.designation), ^"%surgeon%") and
            j1.floor in ^[1, 2, 3] and j1.is_active == ^true and q.location == ^"Downtown" and
            ilike(fragment("(?)::TEXT", q.name), ^"%City%") and (q.rating >= ^3 and q.rating <= ^5)
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "join filters with $OR conditions" do
    test "join filter fields inside $OR" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$OR" => [
            %{"floor" => %{"$EQUAL" => 1}},
            %{"floor" => %{"$EQUAL" => 2}}
          ]
        })

      expected_dynamics =
        dynamic(
          [fat_rooms: j],
          j.floor == ^1 or j.floor == ^2
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "mix of direct and join filters inside $OR" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$OR" => [
            %{"name" => %{"$ILIKE" => "%Premium%"}},
            %{"floor" => %{"$GTE" => 5}}
          ]
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j],
          ilike(fragment("(?)::TEXT", q.name), ^"%Premium%") or j.floor >= ^5
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "$OR with fields from different bindings" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$OR" => [
            %{"floor" => %{"$EQUAL" => 1}},
            %{"experience_years" => %{"$GTE" => 20}}
          ]
        })

      expected_dynamics =
        dynamic(
          [fat_rooms: j1, fat_doctors: j2],
          j1.floor == ^1 or j2.experience_years >= ^20
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "join filters with $AND conditions" do
    test "join filter fields inside $AND" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$AND" => [
            %{"floor" => %{"$GTE" => 2}},
            %{"is_active" => %{"$EQUAL" => true}}
          ]
        })

      expected_dynamics =
        dynamic(
          [fat_rooms: j],
          j.floor >= ^2 and j.is_active == ^true
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "mix of direct and join filters inside $AND" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$AND" => [
            %{"rating" => %{"$GTE" => 4}},
            %{"floor" => %{"$LTE" => 3}},
            %{"experience_years" => %{"$GTE" => 5}}
          ]
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j1, fat_doctors: j2],
          q.rating >= ^4 and j1.floor <= ^3 and j2.experience_years >= ^5
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "complex nested conditions with join filters" do
    test "$OR containing nested $AND with join filters" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$OR" => [
            %{
              "name" => %{"$ILIKE" => "%Premium%"},
              "$AND" => [
                %{"floor" => %{"$GTE" => 3}},
                %{"is_active" => %{"$EQUAL" => true}}
              ]
            },
            %{
              "rating" => %{"$GTE" => 5}
            }
          ]
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j],
          (j.floor >= ^3 and j.is_active == ^true and
             ilike(fragment("(?)::TEXT", q.name), ^"%Premium%")) or q.rating >= ^5
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "$AND containing nested $OR with join filters from different bindings" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$AND" => [
            %{"rating" => %{"$GTE" => 3}},
            %{
              "$OR" => [
                %{"floor" => %{"$IN" => [1, 2]}},
                %{"experience_years" => %{"$GTE" => 15}}
              ]
            }
          ]
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j1, fat_doctors: j2],
          q.rating >= ^3 and
            (j1.floor in ^[1, 2] or j2.experience_years >= ^15)
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "deeply nested with all filter types" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$OR" => [
            %{
              "name" => %{"$ILIKE" => "%City%"},
              "$OR" => [
                %{"floor" => %{"$EQUAL" => 1}},
                %{"is_active" => %{"$EQUAL" => true}}
              ]
            },
            %{
              "rating" => %{"$GTE" => 4},
              "$AND" => [
                %{"experience_years" => %{"$GTE" => 10}},
                %{"designation" => %{"$EQUAL" => "Chief"}}
              ]
            }
          ]
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j1, fat_doctors: j2],
          ((j1.floor == ^1 or j1.is_active == ^true) and
             ilike(fragment("(?)::TEXT", q.name), ^"%City%")) or
            (j2.experience_years >= ^10 and j2.designation == ^"Chief" and q.rating >= ^4)
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "triple nested with multiple bindings and operators" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "$OR" => [
            %{
              "location" => %{"$EQUAL" => "Downtown"},
              "$AND" => [
                %{"floor" => %{"$GTE" => 2}},
                %{"designation" => %{"$IN" => ["Surgeon", "Specialist"]}}
              ]
            },
            %{
              "$OR" => [
                %{"rating" => %{"$EQUAL" => 5}},
                %{
                  "total_staff" => %{"$GTE" => 100},
                  "experience_years" => %{"$GTE" => 20}
                }
              ]
            }
          ]
        })

      expected_dynamics =
        dynamic(
          [q, fat_rooms: j1, fat_doctors: j2],
          (j1.floor >= ^2 and j2.designation in ^["Surgeon", "Specialist"] and
             q.location == ^"Downtown") or
            (q.rating == ^5 or (j2.experience_years >= ^20 and q.total_staff >= ^100))
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "join filters with overrideable fields" do
    test "combines join filter with overrideable active_hospital filter" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "active_hospital" => %{"$EQUAL" => true},
          "floor" => %{"$EQUAL" => 1}
        })

      expected_dynamics =
        dynamic(
          [h, fat_rooms: j],
          h.total_staff > 0 and h.rating >= 3 and j.floor == ^1
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "combines multiple join filters with overrideable search" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "search" => %{"$ILIKE" => "Medical"},
          "floor" => %{"$GTE" => 2},
          "experience_years" => %{"$GTE" => 5}
        })

      expected_dynamics =
        dynamic(
          [h, fat_rooms: j1, fat_doctors: j2],
          j2.experience_years >= ^5 and j1.floor >= ^2 and
            (ilike(h.name, ^"%Medical%") or ilike(h.location, ^"%Medical%"))
        )

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "join filters with direct value (no operator map)" do
    test "handles direct value assignment for join filter field" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{"floor" => 3})

      expected_dynamics = dynamic([fat_rooms: j], j.floor == ^3)

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "handles nil value for join filter field" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{"purpose" => nil})

      expected_dynamics = dynamic([fat_rooms: j], is_nil(j.purpose))

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end

  describe "empty and default behavior" do
    test "returns default dynamic when no filters provided" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{})

      expected_dynamics = dynamic([q], true)

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "returns default dynamic when only ignoreable values provided" do
      dynamics = HospitalJoinDynamicsBuilder.build(%{"name" => "", "location" => nil})

      expected_dynamics = dynamic([q], true)

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end

    test "ignores unknown fields but applies valid join filters" do
      dynamics =
        HospitalJoinDynamicsBuilder.build(%{
          "unknown_field" => "value",
          "floor" => %{"$EQUAL" => 1}
        })

      expected_dynamics = dynamic([fat_rooms: j], j.floor == ^1)

      assert query_to_sql(dynamics) == expected_to_sql(expected_dynamics)
    end
  end
end
