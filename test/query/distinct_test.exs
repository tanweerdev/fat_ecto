defmodule Query.DistinctTest do
  use FatEcto.ConnCase

  setup do
    Application.delete_env(:fat_ecto, :fat_ecto, [:blacklist_params])

    :ok
  end

  test "returns the query where name is distinct " do
    Repo.insert!(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert!(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{
      "$distinct" => "name"
    }

    expected = from(h in FatEcto.FatHospital, distinct: [asc: h.name])

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) |> length() == 1
  end

  test "returns the query where phone is distinct and blacklisted " do
    Repo.insert!(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert!(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["level", "nurses"]}, {:fat_hospitals, ["phone"]}]
    )

    opts = %{
      "$distinct" => "phone"
    }

    assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatHospital, opts) end
  end

  test "returns the query where field is boolean" do
    Repo.insert!(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert!(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{
      "$distinct" => true
    }

    expected = from(h in FatEcto.FatHospital, distinct: true)

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) |> length() == 2
  end

  test "returns the query with nested order_by clause" do
    opts = %{
      "$select" => %{"$fields" => ["designation", "experience_years"]},
      "$full_join" => %{
        "fat_patients" => %{
          "$on_field" => "id",
          "$on_table_field" => "doctor_id",
          "$where" => %{"location" => "bullavard", "phone" => %{"$ilike" => "Joh"}, "symptoms" => "$not_null"},
          "$select" => ["name", "prescription"],
          "$order" => %{"appointments_count" => "$asc"}
        }
      },
      "$distinct_nested" => true,
      "$distinct" => true
    }

    expected =
      from(f0 in FatEcto.FatDoctor,
        full_join: f1 in "fat_patients",
        on: f0.id == f1.doctor_id,
        where:
          not is_nil(f1.symptoms) and
            (ilike(fragment("(?)::TEXT", f1.phone), ^"Joh") and (f1.location == ^"bullavard" and ^true)),
        distinct: true,
        select:
          merge(map(f0, [:designation, :experience_years]), %{
            ^"fat_patients" => map(f1, [:name, :prescription])
          })
      )

    query = Query.build!(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)
  end

  test "returns the query with outer order_by clause" do
    opts = %{
      "$select" => %{"$fields" => ["designation", "experience_years"]},
      "$full_join" => %{
        "fat_patients" => %{
          "$on_field" => "id",
          "$on_table_field" => "doctor_id",
          "$where" => %{"location" => "bullavard", "phone" => %{"$ilike" => "Joh"}, "symptoms" => "$not_null"},
          "$select" => ["name", "prescription"]
        }
      },
      "$order" => %{"appointments_count" => "$asc"},
      "$distinct" => true
    }

    expected =
      from(f0 in FatEcto.FatDoctor,
        full_join: f1 in "fat_patients",
        on: f0.id == f1.doctor_id,
        where:
          not is_nil(f1.symptoms) and
            (ilike(fragment("(?)::TEXT", f1.phone), ^"Joh") and (f1.location == ^"bullavard" and ^true)),
        order_by: [asc: f0.appointments_count],
        distinct: true,
        select:
          merge(map(f0, [:designation, :experience_years]), %{
            ^"fat_patients" => map(f1, [:name, :prescription])
          })
      )

    query = Query.build!(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)
  end

  test "returns the query with join, include and outer order_by" do
    opts = %{
      "$select" => %{"$fields" => ["designation", "experience_years"]},
      "$full_join" => %{
        "fat_patients" => %{
          "$on_field" => "id",
          "$on_table_field" => "doctor_id",
          "$where" => %{"location" => "bullavard", "phone" => %{"$ilike" => "Joh"}, "symptoms" => "$not_null"},
          "$select" => ["name", "prescription"],
          "$order" => %{"appointments_count" => "$asc"}
        }
      },
      "$include" => %{
        "fat_hospitals" => %{
          "$limit" => 10,
          "$order" => %{"id" => "$asc"},
          "$where" => %{"id" => 10}
        }
      },
      "$order" => %{"experience_years" => "$asc"},
      "$distinct" => true,
      "$distinct_nested" => true
    }

    expected =
      from(f0 in FatEcto.FatDoctor,
        full_join: f1 in "fat_patients",
        on: f0.id == f1.doctor_id,
        left_join: f2 in assoc(f0, :fat_hospitals),
        where:
          not is_nil(f1.symptoms) and
            (ilike(fragment("(?)::TEXT", f1.phone), ^"Joh") and (f1.location == ^"bullavard" and ^true)),
        where: f2.id == ^10 and ^true,
        order_by: [asc: f0.experience_years],
        limit: ^10,
        offset: ^0,
        distinct: true,
        select:
          merge(map(f0, [:designation, :experience_years]), %{
            ^"fat_patients" => map(f1, [:name, :prescription])
          }),
        preload: [:fat_hospitals]
      )

    query = Query.build!(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)
  end
end
