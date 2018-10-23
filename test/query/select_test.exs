defmodule Query.SelectTest do
  use ExUnit.Case
  import FatEcto.FatQuery  
  import Ecto.Query

  test "returns the select query fields" do
    opts = %{
      "$select" => %{"$fields" => ["name", "designation", "experience_years"]}
    }

    expected = from(d in FatEcto.FatDoctor, select: map(d, [:name, :designation, :experience_years]))

    assert inspect(build(FatEcto.FatDoctor, opts)) == inspect(expected)
  end

  test "returns the select query with related fields " do
    opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "rooms" => ["beds", "patients"]
      }
    }

    expected =
      from(
        h in FatEcto.FatHospital ,
        select: map(h, [:name, :location, :rating, :id, {:rooms, [:beds, :patients]}])
      )

    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the select query with related fields with order by " do
    opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "rooms" => ["beds", "patients"]
      },
      "$order" => %{"id" => "$desc"}

    }

    expected =
      from(
        h in FatEcto.FatHospital ,
        order_by: [desc: h.id],        
        select: map(h, [:name, :location, :rating, :id, {:rooms, [:beds, :patients]}])
      )

    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the select query with related fields with order by/where " do
    opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "rooms" => ["beds", "patients"]
      },
      "$order" => %{"id" => "$desc"},
      "$where" => %{"rating" => 4}

    }

    expected =
      from(
        h in FatEcto.FatHospital ,
        where: h.rating == ^4,
        order_by: [desc: h.id],        
        select: map(h, [:name, :location, :rating, :id, {:rooms, [:beds, :patients]}])
      )

    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the select query with related fields with order by/where/include " do
    opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "rooms" => ["beds", "patients"]
      },
      "$order" => %{"id" => "$desc"},
      "$where" => %{"rating" => 4},
      "$include" => %{
        "doctors" => %{
          "$include" => ["patients"],
          "$where" => %{"name" => "ham"},
          "$order" => %{"id" => "$desc"}

        }
      }

    }

    query = from d in FatEcto.FatDoctor, left_join: p in assoc(d, :patients), where: d.name == ^"ham", order_by: [desc: d.id], limit: ^10, offset: ^0, preload: [:patients]


    expected =
      from(
        h in FatEcto.FatHospital ,
        join: d in assoc(h, :doctors),
        where: h.rating == ^4,
        order_by: [desc: h.id],        
        select: map(h, [:name, :location, :rating, :id, {:rooms, [:beds, :patients]}]),
         preload: [doctors: ^query ]
      )

     assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end
end
