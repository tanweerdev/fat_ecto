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

    query = Query.build(FatEcto.FatHospital, opts)
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

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatHospital, opts) end
  end

  test "returns the query where field is boolean" do
    Repo.insert!(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert!(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{
      "$distinct" => true
    }

    expected = from(h in FatEcto.FatHospital, distinct: [asc: h.id])

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) |> length() == 2
  end
end
