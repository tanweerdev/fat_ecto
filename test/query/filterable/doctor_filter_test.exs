defmodule DoctorFilterTest do
  use FatEcto.ConnCase

  describe "DoctorFilter" do
    test "returns the query where field like" do
      opts = %{"email" => %{"$like" => "%test%"}}

      expected =
        from(d in FatEcto.FatDoctor, where: like(fragment("(?)::TEXT", d.email), ^"%test%") and ^true)

      query = DoctorFilter.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query where field ilike" do
      opts = %{"email" => %{"$ilike" => "%test%"}}

      expected =
        from(d in FatEcto.FatDoctor, where: ilike(fragment("(?)::TEXT", d.email), ^"%test%") and ^true)

      query = DoctorFilter.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end

    test "applies custom override for phone field" do
      opts = %{"phone" => %{"$ilike" => "%123%"}}
      expected = from(d in FatEcto.FatDoctor, where: ilike(fragment("(?)::TEXT", d.phone), ^"%123%"))
      query = DoctorFilter.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end
  end
end
