defmodule Query.SelectTest do
  use FatEcto.ConnCase

  setup do
    insert(:doctor)
    insert(:hospital)
    room = insert(:room)
    insert(:bed, fat_room_id: room.id)
    Application.delete_env(:fat_ecto, :fat_ecto, [:blacklist_params])

    :ok
  end

  test "returns the select query fields" do
    opts = %{
      "$select" => %{"$fields" => ["email", "designation", "experience_years"]}
    }

    expected = from(d in FatEcto.FatDoctor, select: map(d, [:email, :designation, :experience_years]))

    query = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) == [%{designation: "Surgeon", experience_years: 7, email: "test@test.com"}]
  end

  test "returns the select query with related fields " do
    room = Repo.one(FatEcto.FatRoom)

    opts = %{
      "$select" => %{
        "$fields" => ["name", "purpose", "floor"],
        "fat_beds" => ["purpose", "description", "name"]
      },
      "$where" => %{"id" => room.id}
    }

    expected =
      from(
        f in FatEcto.FatRoom,
        where: f.id == ^room.id and ^true,
        select: map(f, [:name, :purpose, :floor, {:fat_beds, [:purpose, :description, :name]}])
      )

    query = Query.build(FatEcto.FatRoom, opts)
    assert inspect(query) == inspect(expected)

    # TODO: match on results returned
    Repo.all(query)
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
          "$where" => %{"email" => "ham"},
          "$order" => %{"id" => "$desc"}
        }
      }
    }

    query =
      from(
        d in FatEcto.FatDoctor,
        where: d.email == ^"ham" and ^true,
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

  test "returns the select query by removing the blacklist fields" do
    room = Repo.one(FatEcto.FatRoom)

    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["purpose"]}, {:fat_beds, ["purpose", "is_active"]}]
    )

    opts = %{
      "$select" => %{
        "$fields" => ["name", "purpose", "description"],
        "fat_beds" => ["purpose", "description", "is_active"]
      },
      "$where" => %{"id" => room.id}
    }

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatRoom, opts) end
  end

  test "returns the select query by removing the blacklist fields from joining table" do
    room = Repo.one(FatEcto.FatRoom)

    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["example"]}, {:fat_beds, ["purpose", "is_active"]}]
    )

    opts = %{
      "$select" => %{
        "$fields" => ["name", "purpose", "description"],
        "fat_beds" => ["purpose", "description", "is_active"]
      },
      "$where" => %{"id" => room.id}
    }

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatRoom, opts) end
  end

  test "returns the select query list by eliminating the blacklist fields" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["name"]}, {:fat_beds, ["is_active"]}]
    )

    opts = %{
      "$select" => ["name", "purpose", "description"]
    }

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatRoom, opts) end
  end
end
