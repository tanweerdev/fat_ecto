defmodule FatEcto.MultipleSortBuilderTest do
  use FatEcto.ConnCase
  alias FatEcto.DoctorSortBuilder
  alias FatEcto.HospitalSortBuilder
  alias FatEcto.RoomSortBuilder

  describe "Order by when allowed_fields: %{`email` => `$DESC`, `phone` => `$ASC`} passed" do
    test "returns the query with order by on email and phone" do
      opts = %{"email" => "$DESC", "phone" => "$ASC", "name" => "$DESC"}
      expected = from(d in FatEcto.FatDoctor, order_by: [desc: d.email], order_by: [asc: d.phone])
      query = DoctorSortBuilder.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query with order by on email when phone => `$DESC` passed in overrideable_fields" do
      opts = %{"email" => "$DESC", "phone" => "$DESC"}
      expected = from(d in FatEcto.FatDoctor, order_by: [desc: d.email])
      query = DoctorSortBuilder.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end
  end

  describe "Order by when params passed in not_allowed_fields : %{`name` => `$ASC`, `phone` => `$DESC`} & allowed_fields empty" do
    test "returns the query without the order by based on given params" do
      opts = %{
        "name" => "$DESC",
        "phone" => "$ASC"
      }

      expected = FatEcto.FatHospital

      query = HospitalSortBuilder.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end
  end

  describe "Order by when not_allowed_fields there and override not_allowed_fields_fallback" do
    test "returns the query with order when both `name` & `phone` are in not_allowed fields and custom added to query" do
      opts = %{
        "name" => "$ASC",
        "phone" => "$DESC"
      }

      expected =
        from(h in FatEcto.FatRoom, order_by: [asc: h.name], order_by: [desc: h.phone])

      query = RoomSortBuilder.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end
  end
end
