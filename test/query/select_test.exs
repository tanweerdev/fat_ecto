defmodule Query.SelectTest do
  use ExUnit.Case
  import FatEcto.FatQuery
  import Ecto.Query

  test "returns the select query fields" do
    opts = %{
      "$select" => %{"$fields" => ["name", "designation", "experience_years"]}
    }

    expected =
      from(d in FatEcto.FatDoctor, select: map(d, [:name, :designation, :experience_years]))

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the select query with related fields " do
    opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "fat_rooms" => ["beds", "capacity"]
      }
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        select: map(h, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])
      )

    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the select query with related fields with order by " do
    opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "fat_rooms" => ["beds", "capacity"]
      },
      "$order" => %{"id" => "$desc"}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        order_by: [desc: h.id],
        select: map(h, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])
      )

    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the select query with related fields inside direct array" do
    opts = %{
      "$select" => ["name", "location", "rating"]
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        select: map(h, [:name, :location, :rating])
      )

    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the select query with related fields with order by/where " do
    opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "fat_rooms" => ["beds", "capacity"]
      },
      "$order" => %{"id" => "$desc"},
      "$where" => %{"rating" => 4}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^4 and ^true,
        order_by: [desc: h.id],
        select: map(h, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])
      )

    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the select query with related fields with order by/where/include " do
    opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "fat_rooms" => ["beds", "capacity"]
      },
      "$order" => %{"id" => "$desc"},
      "$where" => %{"rating" => 4},
      "$include" => %{
        "fat_doctors" => %{
          "$include" => ["fat_patients"],
          "$where" => %{"name" => "ham"},
          "$order" => %{"id" => "$desc"}
        }
      }
    }

    query =
      from(
        d in FatEcto.FatDoctor,
        left_join: p in assoc(d, :fat_patients),
        where: d.name == ^"ham" and ^true,
        order_by: [desc: d.id],
        limit: ^10,
        offset: ^0,
        preload: [:fat_patients]
      )

    expected =
      from(
        h in FatEcto.FatHospital,
        join: d in assoc(h, :fat_doctors),
        where: h.rating == ^4 and ^true,
        order_by: [desc: h.id],
        select: map(h, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]),
        preload: [fat_doctors: ^query]
      )

    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end
end
