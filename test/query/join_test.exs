defmodule Query.JoinTest do
  use FatEcto.ConnCase

  setup do
    hospital = insert(:hospital)
    insert(:room, fat_hospital_id: hospital.id)
    :ok
  end

  test "returns the query with right join and selected fields" do
    opts = %{
      "$select" => ["name", "location", "phone"],
      "$right_join" => %{
        "fat_roomz" => %{
          "$on_field" => "id",
          "$on_table_field" => "fat_hospital_id",
          "$on_table" => "fat_rooms",
          "$select" => ["name", "purpose", "description"],
          "$where" => %{"name" => "room 1"}
        }
      }
    }

    expected =
      from(
        h in "fat_hospitals",
        right_join: r in "fat_rooms",
        on: h.id == r.fat_hospital_id,
        where: r.name == ^"room 1" and ^true,
        select:
          merge(map(h, [:name, :location, :phone]), %{^"fat_roomz" => map(r, [:name, :purpose, :description])})
      )

    # opts = %{
    #   "$right_join" => %{
    #     "fat_rooms" => %{
    #       "$on_field" => "id",
    #       "$on_table_field" => "fat_hospital_id",
    #       "$select" => ["name", "purpose", "description"],
    #       "$where" => %{"name" => "room 1"}
    #     }
    #   }
    # }

    # expected =
    #   from(
    #     h in FatEcto.FatHospital,
    #     right_join: r in "fat_rooms",
    #     on: h.id == r.fat_hospital_id,
    #     where: r.name == ^"room 1" and ^true,
    #     select: merge(h, %{^:fat_rooms => map(r, [:name, :purpose, :description])})
    #   )

    query = Query.build("fat_hospitals", opts)

    assert inspect(query) == inspect(expected)
    # TODO: match on results returned
    Repo.all(query)
  end

  test "returns the query with left join and selected fields" do
    opts = %{
      "$right_join" => %{
        "fat_rooms" => %{
          "$on_field" => "id",
          "$on_table_field" => "hospital_id",
          "$select" => ["beds", "capacity", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3 and ^true,
        right_join: r in "fat_rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John" and ^true,
        select: merge(h, %{^"fat_rooms" => map(r, [:beds, :capacity, :level])})
      )

    result = Query.build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with full join and selected fields" do
    opts = %{
      "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
      "$full_join" => %{
        "fat_patients" => %{
          "$on_field" => "id",
          "$on_table_field" => "doctor_id",
          "$select" => ["name", "prescription", "symptoms"]
        }
      }
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        full_join: p in "fat_patients",
        on: d.id == p.doctor_id,
        select:
          merge(map(d, [:name, :designation, :experience_years]), %{
            ^"fat_patients" => map(p, [:name, :prescription, :symptoms])
          })
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with inner join and selected fields" do
    opts = %{
      "$inner_join" => %{
        "fat_rooms" => %{
          "$on_field" => "id",
          "$on_table_field" => "hospital_id",
          "$select" => ["beds", "capacity", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3 and ^true,
        inner_join: r in "fat_rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John" and ^true,
        select: merge(h, %{^"fat_rooms" => map(r, [:beds, :capacity, :level])})
      )

    result = Query.build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with inner join and selected fields and additional on clause $in" do
    opts = %{
      "$inner_join" => %{
        "fat_rooms" => %{
          "$on_field" => "id",
          "$on_table_field" => "hospital_id",
          "$additional_on_clauses" => %{
            "rating" => %{"$in" => [1, 2, 3]}
          },
          "$select" => ["beds", "capacity", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3 and ^true,
        inner_join: r in "fat_rooms",
        on: h.rating in ^[1, 2, 3] and h.id == r.hospital_id,
        where: r.incharge == ^"John" and ^true,
        select: merge(h, %{^"fat_rooms" => map(r, [:beds, :capacity, :level])})
      )

    result = Query.build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with inner join and selected fields and additional on clause $between" do
    opts = %{
      "$inner_join" => %{
        "fat_rooms" => %{
          "$on_field" => "id",
          "$on_table_field" => "hospital_id",
          "$additional_on_clauses" => %{
            "rating" => %{"$between_equal" => [1, 3]}
          },
          "$select" => ["beds", "capacity", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3 and ^true,
        inner_join: r in "fat_rooms",
        on: h.rating >= ^1 and h.rating <= ^3 and h.id == r.hospital_id,
        where: r.incharge == ^"John" and ^true,
        select: merge(h, %{^"fat_rooms" => map(r, [:beds, :capacity, :level])})
      )

    result = Query.build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with inner join and selected fields and inner where" do
    opts = %{
      "$inner_join" => %{
        "fat_rooms" => %{
          "$on_field" => "id",
          "$on_table_field" => "hospital_id",
          "$select" => ["beds", "capacity", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3 and ^true,
        inner_join: r in "fat_rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John" and ^true,
        select: merge(h, %{^"fat_rooms" => map(r, [:beds, :capacity, :level])})
      )

    result = Query.build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with inner join and selected fields and outer where" do
    opts = %{
      "$right_join" => %{
        "fat_rooms" => %{
          "$on_field" => "id",
          "$on_table_field" => "hospital_id",
          "$select" => ["beds", "capacity", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3 and ^true,
        right_join: r in "fat_rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John" and ^true,
        select: merge(h, %{^"fat_rooms" => map(r, [:beds, :capacity, :level])})
      )

    result = Query.build(FatEcto.FatHospital, opts)

    assert inspect(result) == inspect(expected)
  end
end
