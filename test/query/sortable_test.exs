defmodule Query.SortableTest do
  use FatEcto.ConnCase

  describe "Order by when allowed_fields: %{`email` => `$desc`, `phone` => `$asc`} passed" do
    test "returns the query with order by on email and phone" do
      opts = %{"email" => "$desc", "phone" => "$asc", "name" => "$desc"}
      expected = from(d in FatEcto.FatDoctor, order_by: [desc: d.email], order_by: [asc: d.phone])
      query = DoctorOrderby.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query with order by on email when phone => `$desc` passed in overrideable_fields" do
      opts = %{"email" => "$desc", "phone" => "$desc"}
      expected = from(d in FatEcto.FatDoctor, order_by: [desc: d.email])
      query = DoctorOrderby.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end
  end

  describe "Order by when params passed in not_allowed_fields : %{`name` => `$asc`, `phone` => `$desc`} & allowed_fields empty" do
    test "returns the query without the order by based on given params" do
      opts = %{
        "name" => "$desc",
        "phone" => "$asc"
      }

      expected = FatEcto.FatHospital

      query = HospitalOrderby.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end
  end

  describe "Order by when not_allowed_fields there and override not_allowed_fields_fallback" do
    test "returns the query with order when both `name` & `phone` are in not_allowed fields and custom added to query" do
      opts = %{
        "name" => "$asc",
        "phone" => "$desc"
      }

      expected =
        from(h in FatEcto.FatRoom, order_by: [asc: h.name], order_by: [desc: h.phone])

      query = RoomOrderby.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end
  end
end
