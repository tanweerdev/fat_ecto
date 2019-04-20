defmodule Query.OrderTest do
  use FatEcto.ConnCase

  test "returns the query where field is desc " do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{
      "$order" => %{"rating" => "$desc"}
    }

    expected = from(h in FatEcto.FatHospital, order_by: [desc: h.rating])

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) |> Enum.map(fn map -> map.rating end) == [10, 6]
  end

  test "returns the query where field is asc " do
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 4})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 6})

    opts = %{
      "$order" => %{"appointments_count" => "$asc"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [asc: p.appointments_count])

    query = Query.build(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.all(query) |> Enum.map(fn map -> map.appointments_count end) == [4, 6]
  end
end
