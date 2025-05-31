defmodule FatEcto.Query.Dynamics.BuilderTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.Query.Dynamics.Builder

  describe "build/1" do
    test "handles simple field comparisons" do
      dynamics =
        Builder.build(%{
          "name" => %{"$ILIKE" => "%John%"},
          "age" => %{"$GT" => 18, "$LT" => 30}
        })

      expected_dynamics =
        dynamic([q], q.age > ^18 and q.age < ^30 and ilike(fragment("(?)::TEXT", q.name), ^"%John%"))

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles direct field comparisons" do
      dynamics =
        Builder.build(%{
          "name" => "John",
          "age" => 25
        })

      expected_dynamics = dynamic([q], q.age == ^25 and q.name == ^"John")

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles nil values" do
      dynamics =
        Builder.build(%{
          "name" => nil,
          "age" => %{"$GT" => 18}
        })

      expected_dynamics = dynamic([q], q.age > ^18 and is_nil(q.name))

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles nested $OR conditions" do
      dynamics =
        Builder.build(%{
          "$OR" => [
            %{"name" => %{"$ILIKE" => "%John%"}},
            %{"age" => %{"$GT" => 30}}
          ]
        })

      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^"%John%") or q.age > ^30)

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles nested $AND conditions" do
      dynamics =
        Builder.build(%{
          "$AND" => [
            %{"name" => %{"$ILIKE" => "%John%"}},
            %{"age" => %{"$GT" => 18}}
          ]
        })

      expected_dynamics = dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^"%John%") and q.age > ^18)

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles deeply nested conditions" do
      dynamics =
        Builder.build(%{
          "$OR" => [
            %{
              "name" => %{"$ILIKE" => "%John%"},
              "$OR" => [
                %{"age" => %{"$GT" => 18}},
                %{"city" => "New York"}
              ]
            },
            %{
              "status" => "active",
              "$AND" => [
                %{"rating" => %{"$GT" => 4}},
                %{"total_staff" => %{"$GTE" => 20}}
              ]
            }
          ]
        })

      expected_dynamics =
        dynamic(
          [q],
          ((q.age > ^18 or q.city == ^"New York") and ilike(fragment("(?)::TEXT", q.name), ^"%John%")) or
            (q.rating > ^4 and q.total_staff >= ^20 and q.status == ^"active")
        )

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles deeply nested conditions with $OR as map" do
      dynamics =
        Builder.build(%{
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
        })

      expected_dynamics =
        dynamic(
          [q],
          ((q.location == ^"New York" or q.rating > ^18) and ilike(fragment("(?)::TEXT", q.name), ^"%John%")) or
            (q.rating > ^4 and q.email == ^"fat_ecto@example.com" and q.start_date == ^"2023-01-01")
        )

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles boolean fields" do
      dynamics =
        Builder.build(%{
          "is_active" => true
        })

      expected_dynamics = dynamic([q], q.is_active == ^true)

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles multiple operators for the same field" do
      dynamics =
        Builder.build(%{
          "age" => %{"$GT" => 18, "$LT" => 30}
        })

      expected_dynamics = dynamic([q], q.age > ^18 and q.age < ^30)

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles $IN operator for list values" do
      dynamics =
        Builder.build(%{
          "city" => %{"$IN" => ["New York", "London"]}
        })

      expected_dynamics = dynamic([q], q.city in ^["New York", "London"])

      assert inspect(dynamics) == inspect(expected_dynamics)
    end

    test "handles $NOT_IN operator for list values" do
      dynamics =
        Builder.build(%{
          "city" => %{"$NOT_IN" => ["New York", "London"]}
        })

      expected_dynamics = dynamic([q], q.city not in ^["New York", "London"])

      assert inspect(dynamics) == inspect(expected_dynamics)
    end
  end
end
