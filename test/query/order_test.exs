defmodule Query.OrderTest do
  use FatEcto.ConnCase

  setup do
    hospital = insert(:hospital)
    insert(:room, fat_hospital_id: hospital.id)

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
    results = Repo.all(query)

    assert inspect(query) == inspect(expected)
    assert Enum.map(results, fn map -> map.rating end) == [10, 6, 5]
  end

  test "returns the query where field is desc and blacklisted" do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{
      "$order" => %{"phone" => "$desc"}
    }

    expected = from(p in FatEcto.FatHospital, order_by: [desc: p.phone])

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
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
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.appointments_count end) == [4, 6]
  end

  test "returns the query where field is asc_null_last" do
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 4})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 6})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234"})

    opts = %{
      "$order" => %{"appointments_count" => "$asc_nulls_last"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [asc_nulls_last: p.appointments_count])

    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.appointments_count end) == [4, 6, nil]
  end

  test "returns the query where field is asc_null_first" do
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 4})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 6})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234"})

    opts = %{
      "$order" => %{"appointments_count" => "$asc_nulls_first"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [asc_nulls_first: p.appointments_count])

    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.appointments_count end) == [nil, 4, 6]
  end

  test "returns the query where field is desc_null_first" do
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 4})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 6})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234"})

    opts = %{
      "$order" => %{"appointments_count" => "$desc_nulls_first"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [desc_nulls_first: p.appointments_count])

    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.appointments_count end) == [nil, 6, 4]
  end

  test "returns the query where field is desc_null_last" do
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 4})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 6})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234"})

    opts = %{
      "$order" => %{"appointments_count" => "$desc_nulls_last"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [desc_nulls_last: p.appointments_count])

    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.appointments_count end) == [6, 4, nil]
  end

  test "returns the query where field is asc" do
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 4})
    Repo.insert(%FatEcto.FatPatient{name: "Doe", phone: "1234", appointments_count: 6})

    opts = %{
      "$order" => %{"date_of_birth" => "$asc"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [asc: p.date_of_birth])
    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
  end
end
