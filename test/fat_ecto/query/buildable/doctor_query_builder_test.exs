defmodule FatDoctor.QueryTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatDoctor

  alias FatEcto.Query.DoctorQueryBuilder

  describe "build/3" do
    test "filters by email with $EQUAL operator" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"email" => "test@example.com"})

      expected_query = from(d in FatDoctor, where: d.email == ^"test@example.com")
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by email with $ilike operator (lowercase)" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"email" => %{"$ilike" => "%test%"}})

      expected_query = from(d in FatDoctor, where: ilike(fragment("(?)::TEXT", d.email), ^"%test%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "ignores email with ignoreable value" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"email" => ""})

      assert query == base_query
    end

    test "filters by name with direct comparison" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"name" => "John"})

      expected_query = from(d in FatDoctor, where: d.name == ^"John")
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by name with $Like operator (mixed case)" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"name" => %{"$Like" => "%John%"}})

      expected_query = from(d in FatDoctor, where: like(fragment("(?)::TEXT", d.name), ^"%John%"))
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by phone with custom $ILIKE operator" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"phone" => %{"$ILIKE" => "%123%"}})

      expected_query = from(d in FatDoctor, where: ilike(fragment("(?)::TEXT", d.phone), ^"%123%"))
      assert inspect(query) == inspect(expected_query)
    end

    @tag :skip
    test "filters by phone with custom $ILIKE operator and name with standard buildable" do
      base_query = from(d in FatDoctor)

      query =
        DoctorQueryBuilder.build(base_query, %{
          "phone" => %{"$ILIKE" => "%123%"},
          "name" => %{"$EQUAL" => "John"}
        })

      expected_query =
        from(d in FatDoctor, where: d.name == ^"John" and ilike(fragment("(?)::TEXT", d.phone), ^"%123%"))

      assert inspect(query) == inspect(expected_query)
    end

    @tag :skip
    test "filters with complex params" do
      base_query = from(d in FatDoctor)

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

      query = DoctorQueryBuilder.build(base_query, params)

      expected_query =
        from(d in FatDoctor,
          where:
            ((d.rating > ^18 or d.location == ^"New York") and
               ilike(fragment("(?)::TEXT", d.name), ^"%John%")) or
              (d.rating > ^4 and d.email == ^"fat_ecto@example.com" and d.start_date == ^"2023-01-01")
        )

      assert inspect(query) == inspect(expected_query)
    end

    @tag :skip
    test "filters with complex params but with $OR as map" do
      base_query = from(d in FatDoctor)

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

      query = DoctorQueryBuilder.build(base_query, params)

      expected_query =
        from(d in FatDoctor,
          where:
            ((d.location == ^"New York" or d.rating > ^18) and
               ilike(fragment("(?)::TEXT", d.name), ^"%John%")) or
              (d.rating > ^4 and d.email == ^"fat_ecto@example.com" and d.start_date == ^"2023-01-01")
        )

      assert inspect(query) == inspect(expected_query)
    end

    test "ignores phone with ignoreable value" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"phone" => nil})

      assert query == base_query
    end

    test "filters by rating with $gt operator (lowercase)" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"rating" => %{"$gt" => 4}})

      expected_query = from(d in FatDoctor, where: d.rating > ^4)
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by start_date with $Gte operator (mixed case)" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"start_date" => %{"$Gte" => "2023-01-01"}})

      expected_query = from(d in FatDoctor, where: d.start_date >= ^"2023-01-01")
      assert inspect(query) == inspect(expected_query)
    end

    test "filters by location with $IN operator" do
      base_query = from(d in FatDoctor)
      query = DoctorQueryBuilder.build(base_query, %{"location" => %{"$IN" => ["New York", "London"]}})

      expected_query = from(d in FatDoctor, where: d.location in ^["New York", "London"])
      assert inspect(query) == inspect(expected_query)
    end
  end
end
