defmodule Query.SelectTest do
  use FatEcto.ConnCase

  setup do
    insert(:doctor)
    insert(:hospital)
    room = insert(:room)
    insert(:bed, fat_room_id: room.id)
    :ok
  end

  test "returns the select query fields" do
    opts = %{
      "$select" => %{"$fields" => ["name", "designation", "experience_years"]}
    }

    expected = from(d in FatEcto.FatDoctor, select: map(d, [:name, :designation, :experience_years]))

    query = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) == [%{designation: "Surgeon", experience_years: 7, name: "John"}]
  end

  @tag :failing
  test "returns the select query with related fields " do
    room = Repo.one(FatEcto.FatRoom)

    opts = %{
      "$select" => %{
        "$fields" => ["name", "purpose", "description"],
        "fat_beds" => ["purpose", "description", "is_active"]
      },
      "$where" => %{"id" => room.id}
    }

    expected =
      from(
        f in FatEcto.FatRoom,
        where: f.id == ^room.id and ^true,
        select: map(f, [:name, :purpose, :description, {:fat_beds, [:purpose, :description, :is_active]}])
      )

    query = Query.build(FatEcto.FatRoom, opts)
    assert inspect(query) == inspect(expected)

    Repo.all(query)
    |> IO.inspect()
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
        select: map(h, [:name, :location, :rating, {:fat_rooms, [:beds, :capacity]}])
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
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

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
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
        select: map(h, [:name, :location, :rating, {:fat_rooms, [:beds, :capacity]}])
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
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
          "$limit" => 200,
          "$where" => %{"name" => "ham"},
          "$order" => %{"id" => "$desc"}
        }
      }
    }

    query =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"ham" and ^true,
        order_by: [desc: d.id],
        limit: ^107,
        offset: ^0,
        preload: [:fat_patients]
      )

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^4 and ^true,
        order_by: [desc: h.id],
        select: map(h, [:name, :location, :rating, {:fat_rooms, [:beds, :capacity]}]),
        preload: [fat_doctors: ^query]
      )

    query = Query.build(FatEcto.FatHospital, opts, max_limit: 107)
    assert inspect(query) == inspect(expected)
  end
end
