defmodule Query.WhereTest do
  use ExUnit.Case
  import FatEcto.FatQuery
  import Ecto.Query

  test "returns the query where field like" do
    opts = %{
      "$where" => %{"name" => %{"$like" => "%Joh %"}}
    }

    expected = from(d in FatEcto.FatDoctor, where: like(d.name, ^"%Joh %"))

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field ilike" do
    opts = %{
      "$where" => %{"designation" => %{"$ilike" => "%surge %"}}
    }

    expected = from(d in FatEcto.FatDoctor, where: ilike(d.designation, ^"%surge %"))
    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field notlike" do
    opts = %{
      "$where" => %{"email" => %{"$not_like" => "%john@ %"}}
    }

    expected = from(d in FatEcto.FatDoctor, where: not like(d.email, ^"%john@ %"))
    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field notilike" do
    opts = %{
      "$where" => %{"address" => %{"$not_ilike" => "%street2 %"}}
    }

    expected = from(d in FatEcto.FatDoctor, where: not ilike(d.address, ^"%street2 %"))
    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field lt" do
    opts = %{
      "$where" => %{"rating" => %{"$lt" => 3}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.rating < ^3)
    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field lt another field" do
    opts = %{
      "$where" => %{"total_staff" => %{"$lt" => "$rating"}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.total_staff < h.rating)
    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field lte" do
    opts = %{
      "$where" => %{"total_staff" => %{"$lte" => 3}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.total_staff <= ^3)
    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field lte another field" do
    opts = %{
      "$where" => %{"rating" => %{"$lte" => "$total_staff"}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.rating <= h.total_staff)
    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field gt" do
    opts = %{
      "$where" => %{"beds" => %{"$gt" => 3}}
    }

    expected = from(r in FatEcto.FatRoom, where: r.beds > ^3)
    result = build(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field gt another field" do
    opts = %{
      "$where" => %{"beds" => %{"$gt" => "$capacity"}}
    }

    expected = from(r in FatEcto.FatRoom, where: r.beds > r.capacity)
    result = build(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field gte" do
    opts = %{
      "$where" => %{"capacity" => %{"$gte" => 3}}
    }

    expected = from(r in FatEcto.FatRoom, where: r.capacity >= ^3)
    result = build(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field gte another field" do
    opts = %{
      "$where" => %{"rating" => %{"$gte" => "$total_staff"}}
    }

    expected = from(r in FatEcto.FatRoom, where: r.rating >= r.total_staff)
    result = build(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field between" do
    opts = %{
      "$where" => %{"total_staff" => %{"$between" => [10, 20]}}
    }

    expected = from(r in FatEcto.FatRoom, where: r.total_staff > ^10 and r.total_staff < ^20)
    result = build(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field notbetween" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_between" => [10, 20]}}
    }

    expected =
      from(p in FatEcto.FatPatient, where: p.appointments_count < ^10 or p.appointments_count > ^20)

    result = build(FatEcto.FatPatient, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field in" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$in" => [20, 50]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count in ^[20, 50])
    result = build(FatEcto.FatPatient, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field notin" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_in" => [20, 50]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count not in ^[20, 50])
    result = build(FatEcto.FatPatient, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field isnil" do
    opts = %{
      "$where" => %{"rating" => nil}
    }

    expected = from(h in FatEcto.FatHospital, where: is_nil(h.rating))
    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field not isnil" do
    opts = %{
      "$where" => %{"$notNull" => ["rating"]}
    }

    expected = from(h in FatEcto.FatHospital, where: not is_nil(h.rating))
    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field is binary" do
    opts = %{
      "$where" => %{"location" => "Geo"}
    }

    expected = from(h in FatEcto.FatHospital, where: h.location == ^"Geo")
    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end
end
