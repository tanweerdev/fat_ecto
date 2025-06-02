defmodule FatEcto.HospitalSortBuilderTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.HospitalSortBuilder

  setup do
    hospital = insert(:hospital, rating: 5)
    insert(:room, fat_hospital_id: hospital.id)
    :ok
  end

  defp apply_sort(opts) do
    order_by = HospitalSortBuilder.build(opts)
    from(h in FatEcto.FatHospital, order_by: ^order_by)
  end

  test "returns the query where field is desc" do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{"rating" => "$DESC"}
    query = apply_sort(opts)
    expected = from(h in FatEcto.FatHospital, order_by: [desc: h.rating])

    assert inspect(query) == inspect(expected)
    assert Enum.map(Repo.all(query), & &1.rating) == [10, 6, 5]
  end

  test "returns the query where field is desc and blacklisted" do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 10})
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234", rating: 6})

    opts = %{"phone" => "$DESC"}
    query = apply_sort(opts)
    expected = from(p in FatEcto.FatHospital, order_by: [desc: p.phone])

    assert inspect(query) == inspect(expected)
  end

  test "returns the query where field is asc" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})

    opts = %{"rating" => "$ASC"}
    query = apply_sort(opts)
    expected = from(p in FatEcto.FatHospital, order_by: [asc: p.rating])

    assert inspect(query) == inspect(expected)
    assert Enum.map(Repo.all(query), & &1.rating) == [4, 5, 6]
  end

  test "returns the query where field is asc_null_last" do
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$ASC_NULLS_LAST"}
    query = apply_sort(opts)
    expected = from(f0 in FatEcto.FatHospital, order_by: [asc_nulls_last: f0.rating])

    assert inspect(query) == inspect(expected)
    assert Enum.map(Repo.all(query), & &1.rating) == [4, 5, 6, nil]
  end

  test "does not apply order by if field is not configured" do
    opts = %{"appointments_count" => "$ASC_NULLS_LAST"}
    order_by = HospitalSortBuilder.build(opts)

    assert order_by == []
    query = from(h in FatEcto.FatHospital, order_by: ^order_by)
    expected_query = from(f0 in FatEcto.FatHospital, order_by: [])
    assert inspect(query) == inspect(expected_query)
  end

  test "returns the query where field is asc_null_first" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$ASC_NULLS_FIRST"}
    query = apply_sort(opts)
    expected = from(p in FatEcto.FatHospital, order_by: [asc_nulls_first: p.rating])

    assert inspect(query) == inspect(expected)
    assert Enum.map(Repo.all(query), & &1.rating) == [nil, 4, 5, 6]
  end

  test "returns the query where field is desc_null_first" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$DESC_NULLS_FIRST"}
    query = apply_sort(opts)
    expected = from(p in FatEcto.FatHospital, order_by: [desc_nulls_first: p.rating])

    assert inspect(query) == inspect(expected)
    assert Enum.map(Repo.all(query), & &1.rating) == [nil, 6, 5, 4]
  end

  test "returns the query where field is desc_null_last" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})
    Repo.insert(%FatEcto.FatHospital{})

    opts = %{"rating" => "$DESC_NULLS_LAST"}
    query = apply_sort(opts)
    expected = from(p in FatEcto.FatHospital, order_by: [desc_nulls_last: p.rating])

    assert inspect(query) == inspect(expected)
    assert Enum.map(Repo.all(query), & &1.rating) == [6, 5, 4, nil]
  end

  test "returns the query where field is asc 2" do
    Repo.insert(%FatEcto.FatHospital{rating: 4})
    Repo.insert(%FatEcto.FatHospital{rating: 6})

    opts = %{"date_of_birth" => "$ASC"}
    query = apply_sort(opts)
    expected = from(p in FatEcto.FatHospital, order_by: [asc: p.date_of_birth])

    assert inspect(query) == inspect(expected)
  end
end
