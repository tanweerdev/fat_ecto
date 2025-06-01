defmodule FatEcto.DoctorDynamicsBuilderTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.DoctorDynamicsBuilder

  describe "build/2" do
    test "filters by email with $EQUAL operator" do
      dynamics = DoctorDynamicsBuilder.build(%{"email" => "test@example.com"})
      expected_dynamics = dynamic([q], q.email == ^"test@example.com")
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by email with $ILIKE operator" do
      dynamics = DoctorDynamicsBuilder.build(%{"email" => %{"$ILIKE" => "%test%"}})
      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.email), ^"%test%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores email with ignoreable value" do
      dynamics = DoctorDynamicsBuilder.build(%{"email" => ""})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by name with direct comparison" do
      dynamics = DoctorDynamicsBuilder.build(%{"name" => "John"})
      expected_dynamics = dynamic([q], q.name == ^"John")
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by name with $LIKE operator" do
      dynamics = DoctorDynamicsBuilder.build(%{"name" => %{"$LIKE" => "%John%"}})
      expected_dynamics = dynamic([q], like(fragment("(?)::TEXT", q.name), ^"%John%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by phone with custom $ILIKE operator" do
      dynamics = DoctorDynamicsBuilder.build(%{"phone" => %{"$ILIKE" => "%123%"}})
      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^"%123%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by phone with custom $ILIKE operator and name with standard buildable" do
      dynamics = DoctorDynamicsBuilder.build(%{"phone" => %{"$ILIKE" => "%123%"}, "name" => %{"$EQUAL" => "John"}})
      expected_dynamics = dynamic([q], q.name == ^"John" and ilike(fragment("(?)::TEXT", q.phone), ^"%123%"))
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters with complex params" do
      params = %{
        "$OR" => [
          %{
            "name" => %{"$ILIKE" => "%John%"},
            "$OR" => [
              %{"rating" => %{"$GT" => 18}},
              %{"location" => "New York"}
            ]
          },
          %{
            "start_date" => "2023-01-01",
            "$AND" => [
              %{"rating" => %{"$GT" => 4}},
              %{"email" => "fat_ecto@example.com"}
            ]
          }
        ]
      }

      dynamics = DoctorDynamicsBuilder.build(params)

      expected_dynamics =
        dynamic(
          [q],
          ((q.rating > ^18 or q.location == ^"New York") and ilike(fragment("(?)::TEXT", q.name), ^"%John%")) or
            (q.rating > ^4 and q.email == ^"fat_ecto@example.com" and q.start_date == ^"2023-01-01")
        )

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters with complex params but with $OR as map" do
      params = %{
        "$OR" => [
          %{
            "name" => %{"$ILIKE" => "%John%"},
            "$OR" => %{
              "rating" => %{"$GT" => 18},
              "location" => "New York"
            }
          },
          %{
            "start_date" => "2023-01-01",
            "$AND" => [
              %{"rating" => %{"$GT" => 4}},
              %{"email" => "fat_ecto@example.com"}
            ]
          }
        ]
      }

      dynamics = DoctorDynamicsBuilder.build(params)

      expected_dynamics =
        dynamic(
          [q],
          ((q.location == ^"New York" or q.rating > ^18) and ilike(fragment("(?)::TEXT", q.name), ^"%John%")) or
            (q.rating > ^4 and q.email == ^"fat_ecto@example.com" and q.start_date == ^"2023-01-01")
        )

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "ignores phone with ignoreable value" do
      dynamics = DoctorDynamicsBuilder.build(%{"phone" => nil})
      expected_dynamics = nil
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by rating with $GT operator" do
      dynamics = DoctorDynamicsBuilder.build(%{"rating" => %{"$GT" => 4}})
      expected_dynamics = dynamic([q], q.rating > ^4)
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by start_date with $GTE operator" do
      dynamics = DoctorDynamicsBuilder.build(%{"start_date" => %{"$GTE" => "2023-01-01"}})
      expected_dynamics = dynamic([q], q.start_date >= ^"2023-01-01")
      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "filters by location with $IN operator" do
      dynamics = DoctorDynamicsBuilder.build(%{"location" => %{"$IN" => ["New York", "London"]}})
      expected_dynamics = dynamic([q], q.location in ^["New York", "London"])
      assert inspect(dynamics) == inspect(expected_dynamics)
    end
  end
end
