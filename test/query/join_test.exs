defmodule Query.JoinTest do
  use ExUnit.Case
  alias FatEcto.FatQuery, as: Query
  import Ecto.Query

  test "returns the query with right join and selected fields" do
    opts = %{
      "$right_join" => %{
        "rooms" => %{
          "$on_field" => "id",
          "$on_join_table_field" => "hospital_id",
          "$select" => ["beds", "patients", "level"],
          "$where" => %{"incharge" => "John"}
        }
      }
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        right_join: r in "rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John"
        # select: merge(h, map(r, [:beds, :patients, :level]))
      )

    result = Query.build(FatEcto.FatHospital, opts)

    assert inspect(result) == inspect(expected)
  end

  test "returns the query with left join and selected fields" do
    opts = %{
      "$right_join" => %{
        "rooms" => %{
          "$on_field" => "id",
          "$on_join_table_field" => "hospital_id",
          "$select" => ["beds", "patients", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3,
        right_join: r in "rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John"
        # select: merge(h, map(r, [:beds, :patients, :level]))
      )

    result = Query.build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with full join and selected fields" do
    opts = %{
      "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
      "$full_join" => %{
        "patients" => %{
          "$on_field" => "id",
          "$on_join_table_field" => "doctor_id",
          "$select" => ["name", "prescription", "symptoms"]
        }
      }
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        full_join: p in "patients",
        on: d.id == p.doctor_id
        # select:
        #   merge(
        #     map(d, [:name, :designation, :experience_years]),
        #     map(p, [:name, :prescription, :symptoms])
        #   )
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with inner join and selected fields" do
    opts = %{
      "$inner_join" => %{
        "rooms" => %{
          "$on_field" => "id",
          "$on_join_table_field" => "hospital_id",
          "$select" => ["beds", "patients", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3,
        inner_join: r in "rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John"
        # select: merge(h, map(r, [:beds, :patients, :level]))
      )

    result = Query.build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with inner join and selected fields and inner where" do
    opts = %{
      "$inner_join" => %{
        "rooms" => %{
          "$on_field" => "id",
          "$on_join_table_field" => "hospital_id",
          "$select" => ["beds", "patients", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3,
        inner_join: r in "rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John"
        # select: merge(h, map(r, [:beds, :patients, :level]))
      )

    result = Query.build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with inner join and selected fields and outer where" do
    opts = %{
      "$right_join" => %{
        "rooms" => %{
          "$on_field" => "id",
          "$on_join_table_field" => "hospital_id",
          "$select" => ["beds", "patients", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }

    expected =
      from(
        h in FatEcto.FatHospital,
        where: h.rating == ^3,
        right_join: r in "rooms",
        on: h.id == r.hospital_id,
        where: r.incharge == ^"John",
        # select: merge(h, map(r, [:beds, :patients, :level]))
        select: merge(h, %{^:rooms => map(r, [:beds, :patients, :level])})
      )

    result = Query.build(FatEcto.FatHospital, opts)

    assert inspect(result) == inspect(expected)
  end
end
