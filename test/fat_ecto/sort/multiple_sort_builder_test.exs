defmodule FatEcto.MultipleSortBuilderTest do
  use FatEcto.ConnCase
  alias FatEcto.DoctorSortBuilder
  alias FatEcto.HospitalSortBuilder
  alias FatEcto.RoomSortBuilder
  import Ecto.Query

  defp apply_sort(builder, opts) do
    order_by = builder.build(opts)
    from(q in FatEcto.FatDoctor, order_by: ^order_by)
  end

  describe "Order by when allowed_fields: %{`email` => `$DESC`, `phone` => `$ASC`} passed" do
    test "returns the query with order by on email and phone" do
      opts = %{"email" => "$DESC", "phone" => "$ASC", "name" => "$DESC"}
      query = apply_sort(DoctorSortBuilder, opts)

      expected =
        from(d in FatEcto.FatDoctor,
          order_by: [desc: d.email, asc: d.phone]
        )

      assert inspect(query) == inspect(expected)
    end

    test "returns the query with order by on email when phone => `$DESC` passed in overrideable_fields" do
      opts = %{"email" => "$DESC", "phone" => "$DESC"}
      query = apply_sort(DoctorSortBuilder, opts)

      expected = from(d in FatEcto.FatDoctor, order_by: [desc: d.email])

      assert inspect(query) == inspect(expected)
    end
  end

  describe "Order by when params passed in not_allowed_fields : %{`name` => `$ASC`, `phone` => `$DESC`} & allowed_fields empty" do
    test "returns the query without the order by based on given params" do
      opts = %{
        "name" => "$DESC",
        "phone" => "$ASC"
      }

      order_by = HospitalSortBuilder.build(opts)
      assert order_by == []

      query = from(h in FatEcto.FatHospital, order_by: ^order_by)
      expected_query = from(f0 in FatEcto.FatHospital, order_by: [])
      assert inspect(query) == inspect(expected_query)
    end
  end

  describe "Order by when not_allowed_fields there and override not_allowed_fields_fallback" do
    test "returns the query with order when both `name` & `phone` are in not_allowed fields and custom added to query" do
      opts = %{
        "name" => "$ASC",
        "phone" => "$DESC"
      }

      query = apply_sort(RoomSortBuilder, opts)

      expected =
        from(d in FatEcto.FatDoctor,
          order_by: [asc: d.name, desc: d.phone]
        )

      assert inspect(query) == inspect(expected)
    end
  end
end
