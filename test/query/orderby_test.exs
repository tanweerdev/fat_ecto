defmodule Query.OrderByTest do
  use FatEcto.ConnCase

  setup do
    hospital = insert(:hospital, rating: 5)
    insert(:room, fat_hospital_id: hospital.id)

    :ok
  end

  test "returns the query where field is desc " do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{"rating" => "$desc"}

    expected = from(h in FatEcto.FatHospital, order_by: [desc: h.rating])
    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    results = Repo.all(query)

    assert inspect(query) == inspect(expected)
    assert Enum.map(results, fn map -> map.rating end) == [10, 6, 5]
  end

  test "returns the query where field is desc and blacklisted" do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{"phone" => "$desc"}

    expected = from(p in FatEcto.FatHospital, order_by: [desc: p.phone])

    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
  end

  test "returns the query where field is asc " do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})

    opts = %{"rating" => "$asc"}

    expected = from(p in FatEcto.FatHospital, order_by: [asc: p.rating])

    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [4, 5, 6]
  end

  test "returns the query where field is asc_null_last" do
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$asc_nulls_last"}

    expected = from(f0 in FatEcto.FatHospital, order_by: [asc_nulls_last: f0.rating])

    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [4, 5, 6, nil]
  end

  test "does not apply order by if field is not configured" do
    opts = %{"appointments_count" => "$asc_nulls_last"}

    expected = FatEcto.FatHospital

    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
  end

  test "returns the query where field is asc_null_first" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$asc_nulls_first"}

    expected = from(p in FatEcto.FatHospital, order_by: [asc_nulls_first: p.rating])

    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [nil, 4, 5, 6]
  end

  test "returns the query where field is desc_null_first" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$desc_nulls_first"}

    expected = from(p in FatEcto.FatHospital, order_by: [desc_nulls_first: p.rating])

    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [nil, 6, 5, 4]
  end

  test "returns the query where field is desc_null_last" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$desc_nulls_last"}

    expected = from(p in FatEcto.FatHospital, order_by: [desc_nulls_last: p.rating])

    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [6, 5, 4, nil]
  end

  test "returns the query where field is asc" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})

    opts = %{"date_of_birth" => "$asc"}

    expected = from(p in FatEcto.FatHospital, order_by: [asc: p.date_of_birth])
    query = MyApp.HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
  end
end
