defmodule FatEcto.Dynamics.FatDynamicsBuilderTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.Dynamics.FatDynamicsBuilder

  describe "build/1" do
    test "handles simple field comparisons" do
      query =
        FatDynamicsBuilder.build(%{
          "name" => %{"$ILIKE" => "%John%"},
          "age" => %{"$GT" => 18, "$LT" => 30}
        })

      expected_query =
        dynamic([q], q.age > ^18 and q.age < ^30 and ilike(fragment("(?)::TEXT", q.name), ^"%John%"))

      assert inspect(query) == inspect(expected_query)
    end

    test "handles direct field comparisons" do
      query =
        FatDynamicsBuilder.build(%{
          "name" => "John",
          "age" => 25
        })

      expected_query = dynamic([q], q.age == ^25 and q.name == ^"John")

      assert inspect(query) == inspect(expected_query)
    end

    test "handles nil values" do
      query =
        FatDynamicsBuilder.build(%{
          "name" => nil,
          "age" => %{"$GT" => 18}
        })

      expected_query = dynamic([q], q.age > ^18 and is_nil(q.name))

      assert inspect(query) == inspect(expected_query)
    end

    test "handles nested $OR conditions" do
      query =
        FatDynamicsBuilder.build(%{
          "$OR" => [
            %{"name" => %{"$ILIKE" => "%John%"}},
            %{"age" => %{"$GT" => 30}}
          ]
        })

      expected_query = dynamic([q], q.age > ^30 or ilike(fragment("(?)::TEXT", q.name), ^"%John%"))

      assert inspect(query) == inspect(expected_query)
    end

    test "handles nested $AND conditions" do
      query =
        FatDynamicsBuilder.build(%{
          "$AND" => [
            %{"name" => %{"$ILIKE" => "%John%"}},
            %{"age" => %{"$GT" => 18}}
          ]
        })

      expected_query = dynamic([q], q.age > ^18 and ilike(fragment("(?)::TEXT", q.name), ^"%John%"))

      assert inspect(query) == inspect(expected_query)
    end

    test "handles deeply nested conditions" do
      query =
        FatDynamicsBuilder.build(%{
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

      expected_query =
        dynamic(
          [q],
          (q.total_staff >= ^20 and q.rating > ^4 and q.status == ^"active") or
            ((q.city == ^"New York" or q.age > ^18) and ilike(fragment("(?)::TEXT", q.name), ^"%John%"))
        )

      assert inspect(query) == inspect(expected_query)
    end

    test "handles boolean fields" do
      query =
        FatDynamicsBuilder.build(%{
          "is_active" => true
        })

      expected_query = dynamic([q], q.is_active == ^true)

      assert inspect(query) == inspect(expected_query)
    end

    test "handles multiple operators for the same field" do
      query =
        FatDynamicsBuilder.build(%{
          "age" => %{"$GT" => 18, "$LT" => 30}
        })

      expected_query = dynamic([q], q.age > ^18 and q.age < ^30)

      assert inspect(query) == inspect(expected_query)
    end

    test "handles $IN operator for list values" do
      query =
        FatDynamicsBuilder.build(%{
          "city" => %{"$IN" => ["New York", "London"]}
        })

      expected_query = dynamic([q], q.city in ^["New York", "London"])

      assert inspect(query) == inspect(expected_query)
    end

    test "handles $NOT_IN operator for list values" do
      query =
        FatDynamicsBuilder.build(%{
          "city" => %{"$NOT_IN" => ["New York", "London"]}
        })

      expected_query = dynamic([q], q.city not in ^["New York", "London"])

      assert inspect(query) == inspect(expected_query)
    end
  end
end
