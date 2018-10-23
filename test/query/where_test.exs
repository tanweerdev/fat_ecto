defmodule Query.WhereTest do
  use ExUnit.Case
  import FatEcto.FatQuery  
  import Ecto.Query

  test "returns the query where field like" do
    opts = %{
      "$where" => %{"name" => %{"$like" => "%Joh %"}}
    }

    expected = from(d in FatEcto.FatDoctor, where: like(d.name, ^"%Joh %"))

    assert inspect(build(FatEcto.FatDoctor, opts)) == inspect(expected)
  end

  test "returns the query where field ilike" do
    opts = %{
      "$where" => %{"designation" => %{"$ilike" => "%surge %"}}
    }

    expected = from(d in FatEcto.FatDoctor, where: ilike(d.designation, ^"%surge %"))

    assert inspect(build(FatEcto.FatDoctor, opts)) == inspect(expected)
  end

  test "returns the query where field notlike" do
    opts = %{
      "$where" => %{"email" => %{"$notlike" => "%john@ %"}}
    }

    expected = from(d in FatEcto.FatDoctor, where: not like(d.email, ^"%john@ %"))
    assert inspect(build(FatEcto.FatDoctor, opts)) == inspect(expected)
  end

  test "returns the query where field notilike" do
    opts = %{
      "$where" => %{"address" => %{"$notilike" => "%street2 %"}}
    }

    expected = from(d in FatEcto.FatDoctor, where: not ilike(d.address, ^"%street2 %"))
    assert inspect(build(FatEcto.FatDoctor, opts)) == inspect(expected)
  end

  test "returns the query where field lt" do
    opts = %{
      "$where" => %{"rating" => %{"$lt" => 3}}
    }

    expected = from(h in FatEcto.FatHospital , where: h.rating < ^3)
    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the query where field lt another field" do
    opts = %{
      "$where" => %{"total_staff" => %{"$lt" => "$rating"}}
    }

    expected = from(h in FatEcto.FatHospital , where: h.total_staff < h.rating)
    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the query where field lte" do
    opts = %{
      "$where" => %{"total_staff" => %{"$lte" => 3}}
    }

    expected = from(h in FatEcto.FatHospital , where: h.total_staff <= ^3)

    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the query where field lte another field" do
    opts = %{
      "$where" => %{"rating" => %{"$lte" => "$total_staff"}}
    }

    expected = from(h in FatEcto.FatHospital , where: h.rating <= h.total_staff)

    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the query where field gt" do
    opts = %{
      "$where" => %{"beds" => %{"$gt" => 3}}
    }

    expected = from(r in FatEcto.FatRoom , where: r.beds > ^3)
    assert inspect(build(FatEcto.FatRoom , opts)) == inspect(expected)
  end

  test "returns the query where field gt another field" do
    opts = %{
      "$where" => %{"beds" => %{"$gt" => "$patients"}}
    }

    expected = from(r in FatEcto.FatRoom , where: r.beds > r.patients)

    assert inspect(build(FatEcto.FatRoom , opts)) == inspect(expected)
  end

  test "returns the query where field gte" do
    opts = %{
      "$where" => %{"patients" => %{"$gte" => 3}}
    }

    expected = from(r in FatEcto.FatRoom , where: r.patients >= ^3)

    assert inspect(build(FatEcto.FatRoom , opts)) == inspect(expected)
  end

  test "returns the query where field gte another field" do
    opts = %{
      "$where" => %{"rating" => %{"$gte" => "$total_staff"}}
    }

    expected = from(r in FatEcto.FatRoom , where: r.rating >= r.total_staff)

    assert inspect(build(FatEcto.FatRoom , opts)) == inspect(expected)
  end

  test "returns the query where field between" do
    opts = %{
      "$where" => %{"total_staff" => %{"$between" => [10, 20]}}
    }

    expected = from(r in FatEcto.FatRoom , where: r.total_staff > ^10 and r.total_staff < ^20)
    assert inspect(build(FatEcto.FatRoom , opts)) == inspect(expected)
  end

  test "returns the query where field notbetween" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$notbetween" => [10, 20]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count < ^10 or p.appointments_count > ^20)

    assert inspect(build(FatEcto.FatPatient, opts)) == inspect(expected)
  end

  test "returns the query where field in" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$in" => [20, 50]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count in ^[20, 50])

    assert inspect(build(FatEcto.FatPatient, opts)) == inspect(expected)
  end

  test "returns the query where field notin" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$notin" => [20, 50]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count not in ^[20, 50])

    assert inspect(build(FatEcto.FatPatient, opts)) == inspect(expected)
  end

  test "returns the query where field isnil" do
    opts = %{
      "$where" => %{"rating" => nil}
    }

    expected = from(h in FatEcto.FatHospital , where: is_nil(h.rating))
    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the query where field not isnil" do
    opts = %{
      "$where" => %{"$notNull" => ["rating"]}
    }

    expected = from(h in FatEcto.FatHospital , where: not is_nil(h.rating))
    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the query where field is binary" do
    opts = %{
      "$where" => %{"location" => "Geo"}
    }

    expected = from(h in FatEcto.FatHospital , where: h.location == ^"Geo")
    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end
end
