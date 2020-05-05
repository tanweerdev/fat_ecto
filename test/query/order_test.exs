defmodule Query.OrderTest do
  use FatEcto.ConnCase

  setup do
    hospital = insert(:hospital)
    insert(:room, fat_hospital_id: hospital.id)
    Application.delete_env(:fat_ecto, :fat_ecto, [:blacklist_params])

    :ok
  end

  test "returns the query where field is desc " do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{
      "$order" => %{"rating" => "$desc"}
    }

    expected = from(h in FatEcto.FatHospital, order_by: [desc: h.rating])

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) |> Enum.map(fn map -> map.rating end) == [10, 6, 5]
  end

  test "returns the query where field is desc and blacklisted" do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_doctors, ["id"]}, {:fat_beds, ["is_active"]}, {:fat_hospitals, ["phone"]}]
    )

    opts = %{
      "$order" => %{"phone" => "$desc"}
    }

    assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatHospital, opts) end
  end

  test "returns the query where field is asc " do
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 4})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 6})

    opts = %{
      "$order" => %{"appointments_count" => "$asc"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [asc: p.appointments_count])

    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) |> Enum.map(fn map -> map.appointments_count end) == [4, 6]
  end

  test "returns the query where field is asc and blacklisted" do
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 4})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 6})

    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [
        {:fat_doctors, ["id"]},
        {:fat_beds, ["is_active"]},
        {:fat_patients, ["date_of_birth"]}
      ]
    )

    opts = %{
      "$order" => %{"date_of_birth" => "$asc"}
    }

    assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatPatient, opts) end
  end
end
