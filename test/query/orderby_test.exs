defmodule Query.OrderByTest do
  use FatEcto.ConnCase
  alias MyApp.HospitalOrderby

  setup do
    hospital = insert(:hospital, rating: 5)
    insert(:room, fat_hospital_id: hospital.id)

    :ok
  end

  test "returns the query where field is desc " do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{"rating" => "$DESC"}

    expected = from(h in FatEcto.FatHospital, order_by: [desc: h.rating])
    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    results = Repo.all(query)

    assert inspect(query) == inspect(expected)
    assert Enum.map(results, fn map -> map.rating end) == [10, 6, 5]
  end

  test "returns the query where field is desc and blacklisted" do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{"phone" => "$DESC"}

    expected = from(p in FatEcto.FatHospital, order_by: [desc: p.phone])

    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
  end

  test "returns the query where field is asc " do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})

    opts = %{"rating" => "$ASC"}

    expected = from(p in FatEcto.FatHospital, order_by: [asc: p.rating])

    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [4, 5, 6]
  end

  test "returns the query where field is asc_null_last" do
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$ASC_nulls_last"}

    expected = from(f0 in FatEcto.FatHospital, order_by: [asc_nulls_last: f0.rating])

    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [4, 5, 6, nil]
  end

  test "does not apply order by if field is not configured" do
    opts = %{"appointments_count" => "$ASC_nulls_last"}

    expected = FatEcto.FatHospital

    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
  end

  test "returns the query where field is asc_null_first" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$ASC_nulls_first"}

    expected = from(p in FatEcto.FatHospital, order_by: [asc_nulls_first: p.rating])

    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [nil, 4, 5, 6]
  end

  test "returns the query where field is desc_null_first" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$DESC_nulls_first"}

    expected = from(p in FatEcto.FatHospital, order_by: [desc_nulls_first: p.rating])

    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [nil, 6, 5, 4]
  end

  test "returns the query where field is desc_null_last" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$DESC_nulls_last"}

    expected = from(p in FatEcto.FatHospital, order_by: [desc_nulls_last: p.rating])

    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    results = Repo.all(query)
    assert Enum.map(results, fn map -> map.rating end) == [6, 5, 4, nil]
  end

  test "returns the query where field is asc" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})

    opts = %{"date_of_birth" => "$ASC"}

    expected = from(p in FatEcto.FatHospital, order_by: [asc: p.date_of_birth])
    query = HospitalOrderby.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
  end
end
