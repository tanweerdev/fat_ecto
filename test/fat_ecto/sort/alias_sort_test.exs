defmodule FatEcto.Sort.AliasSortTest do
  @moduledoc false

  use FatEcto.ConnCase
  import Ecto.Query
  alias Ecto.Adapters.SQL
  alias FatEcto.AliasSortBuilder
  alias FatEcto.FatHospital

  defp base_query do
    FatHospital
    |> join(:left, [h], r in assoc(h, :fat_rooms), as: :fat_rooms)
    |> join(:left, [h], d in assoc(h, :fat_doctors), as: :fat_doctors)
  end

  defp sort_to_sql(order_exprs) do
    base_query()
    |> order_by(^order_exprs)
    |> inspect_query()
  end

  defp expected_sort_sql(expected_order) do
    base_query()
    |> order_by(^expected_order)
    |> inspect_query()
  end

  defp direct_sort_to_sql(order_exprs) do
    FatHospital
    |> order_by(^order_exprs)
    |> inspect_query()
  end

  defp direct_expected_sort_sql(expected_order) do
    FatHospital
    |> order_by(^expected_order)
    |> inspect_query()
  end

  defp inspect_query(query) do
    {sql, _params} = SQL.to_sql(:all, FatEcto.Repo, query)
    sql
  end

  describe "sort alias resolution (direct)" do
    test "aliased field sorts by actual schema field ascending" do
      order = AliasSortBuilder.build(%{"hospital_name" => "$ASC"})

      expected = [{:asc, dynamic([h], field(h, :name))}]
      assert direct_sort_to_sql(order) == direct_expected_sort_sql(expected)
    end

    test "aliased field sorts by actual schema field descending" do
      order = AliasSortBuilder.build(%{"hospital_name" => "$DESC"})

      expected = [{:desc, dynamic([h], field(h, :name))}]
      assert direct_sort_to_sql(order) == direct_expected_sort_sql(expected)
    end

    test "aliased field with restricted directions" do
      order = AliasSortBuilder.build(%{"hospital_location" => "$ASC"})

      expected = [{:asc, dynamic([h], field(h, :location))}]
      assert direct_sort_to_sql(order) == direct_expected_sort_sql(expected)
    end

    test "aliased field with disallowed direction is ignored" do
      order = AliasSortBuilder.build(%{"hospital_location" => "$ASC_NULLS_FIRST"})
      assert order == []
    end
  end

  describe "non-aliased sort fields (backward compat)" do
    test "standard field sorts normally" do
      order = AliasSortBuilder.build(%{"id" => "$ASC"})

      expected = [{:asc, dynamic([h], field(h, :id))}]
      assert direct_sort_to_sql(order) == direct_expected_sort_sql(expected)
    end

    test "standard field with restricted directions" do
      order = AliasSortBuilder.build(%{"total_staff" => "$DESC"})

      expected = [{:desc, dynamic([h], field(h, :total_staff))}]
      assert direct_sort_to_sql(order) == direct_expected_sort_sql(expected)
    end

    test "standard field with disallowed direction is ignored" do
      order = AliasSortBuilder.build(%{"total_staff" => "$ASC_NULLS_LAST"})
      assert order == []
    end
  end

  describe "join sort (non-aliased join fields)" do
    test "join field sorts on joined table ascending" do
      order = AliasSortBuilder.build(%{"floor" => "$ASC"})

      expected = [{:asc, dynamic([fat_rooms: r], field(r, :floor))}]
      assert sort_to_sql(order) == expected_sort_sql(expected)
    end

    test "join field sorts on joined table descending" do
      order = AliasSortBuilder.build(%{"floor" => "$DESC"})

      expected = [{:desc, dynamic([fat_rooms: r], field(r, :floor))}]
      assert sort_to_sql(order) == expected_sort_sql(expected)
    end

    test "join field with restricted directions" do
      order = AliasSortBuilder.build(%{"is_active" => "$ASC"})

      expected = [{:asc, dynamic([fat_rooms: r], field(r, :is_active))}]
      assert sort_to_sql(order) == expected_sort_sql(expected)
    end

    test "join field with disallowed direction is ignored" do
      order = AliasSortBuilder.build(%{"is_active" => "$ASC_NULLS_FIRST"})
      assert order == []
    end

    test "join field with nulls variant" do
      order = AliasSortBuilder.build(%{"experience_years" => "$DESC_NULLS_LAST"})

      expected = [{:desc_nulls_last, dynamic([fat_doctors: d], field(d, :experience_years))}]
      assert sort_to_sql(order) == expected_sort_sql(expected)
    end
  end

  describe "join sort (aliased join fields)" do
    test "aliased join field resolves to correct schema field" do
      order = AliasSortBuilder.build(%{"room_name" => "$ASC"})

      expected = [{:asc, dynamic([fat_rooms: r], field(r, :name))}]
      assert sort_to_sql(order) == expected_sort_sql(expected)
    end

    test "aliased join field on different join" do
      order = AliasSortBuilder.build(%{"doctor_name" => "$DESC"})

      expected = [{:desc, dynamic([fat_doctors: d], field(d, :name))}]
      assert sort_to_sql(order) == expected_sort_sql(expected)
    end

    test "aliased join field with restricted directions" do
      order = AliasSortBuilder.build(%{"doctor_rating" => "$ASC"})

      expected = [{:asc, dynamic([fat_doctors: d], field(d, :rating))}]
      assert sort_to_sql(order) == expected_sort_sql(expected)
    end

    test "aliased join field with disallowed direction is ignored" do
      order = AliasSortBuilder.build(%{"doctor_rating" => "$ASC_NULLS_FIRST"})
      assert order == []
    end
  end

  describe "field name conflict resolution in sort" do
    test "main table name and room name sorted independently" do
      order =
        AliasSortBuilder.build(%{
          "hospital_name" => "$ASC",
          "room_name" => "$DESC"
        })

      assert length(order) == 2

      sql = sort_to_sql(order)
      assert sql =~ "ORDER BY"
      assert sql =~ "f0.\"name\""
      assert sql =~ "f1.\"name\""
    end

    test "main table name and doctor name sorted independently" do
      order =
        AliasSortBuilder.build(%{
          "hospital_name" => "$ASC",
          "doctor_name" => "$DESC"
        })

      assert length(order) == 2

      sql = sort_to_sql(order)
      assert sql =~ "f0.\"name\""
      assert sql =~ "f2.\"name\""
    end

    test "all three name fields sorted simultaneously" do
      order =
        AliasSortBuilder.build(%{
          "hospital_name" => "$ASC",
          "room_name" => "$DESC",
          "doctor_name" => "$ASC"
        })

      assert length(order) == 3

      sql = sort_to_sql(order)
      assert sql =~ "f0.\"name\""
      assert sql =~ "f1.\"name\""
      assert sql =~ "f2.\"name\""
    end
  end

  describe "mixed direct and join sorts" do
    test "direct and join fields together" do
      order =
        AliasSortBuilder.build(%{
          "id" => "$DESC",
          "floor" => "$ASC"
        })

      assert length(order) == 2

      sql = sort_to_sql(order)
      assert sql =~ "ORDER BY"
      assert sql =~ "\"id\""
      assert sql =~ "\"floor\""
    end

    test "aliased direct and aliased join fields together" do
      order =
        AliasSortBuilder.build(%{
          "hospital_location" => "$ASC",
          "doctor_rating" => "$DESC"
        })

      assert length(order) == 2

      sql = sort_to_sql(order)
      assert sql =~ "f0.\"location\""
      assert sql =~ "f2.\"rating\""
    end

    test "all field types combined" do
      order =
        AliasSortBuilder.build(%{
          "id" => "$ASC",
          "hospital_name" => "$DESC",
          "floor" => "$ASC",
          "doctor_rating" => "$DESC"
        })

      assert length(order) == 4

      sql = sort_to_sql(order)
      assert sql =~ "\"id\""
      assert sql =~ "f0.\"name\""
      assert sql =~ "f1.\"floor\""
      assert sql =~ "f2.\"rating\""
    end
  end

  describe "overrideable fields alongside join sorts" do
    test "override field works alongside join sort" do
      order =
        AliasSortBuilder.build(%{
          "room_name" => "$ASC",
          "custom_sort" => "$DESC"
        })

      assert length(order) == 2

      sql = sort_to_sql(order)
      assert sql =~ "ORDER BY"
      assert sql =~ "f1.\"name\""
      assert sql =~ "\"rating\""
    end
  end

  describe "edge cases" do
    test "empty params returns empty list" do
      assert AliasSortBuilder.build(%{}) == []
    end

    test "unknown field is dropped" do
      assert AliasSortBuilder.build(%{"nonexistent" => "$ASC"}) == []
    end

    test "non-map input returns empty list" do
      assert AliasSortBuilder.build(nil) == []
    end

    test "original schema field name cannot be used when alias is defined" do
      order = AliasSortBuilder.build(%{"name" => "$ASC"})
      assert order == []
    end

    test "original schema field name for location cannot be used" do
      order = AliasSortBuilder.build(%{"location" => "$ASC"})
      assert order == []
    end

    test "join schema field name cannot be used directly when aliased" do
      order = AliasSortBuilder.build(%{"rating" => "$ASC"})
      assert order == []
    end
  end
end
