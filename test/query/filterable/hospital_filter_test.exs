defmodule HospitalFilterTest do
  use FatEcto.ConnCase

  describe "HospitalFilter" do
    test "returns the query where field like" do
      opts = %{"name" => %{"$like" => "%St. Mary%"}}

      expected =
        from(h in FatEcto.FatHospital, where: like(fragment("(?)::TEXT", h.name), ^"%St. Mary%"))

      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query where field ilike" do
      opts = %{"name" => %{"$ilike" => "%st. mary%"}}

      expected =
        from(h in FatEcto.FatHospital, where: ilike(fragment("(?)::TEXT", h.name), ^"%st. mary%"))

      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end

    test "applies custom override for phone field" do
      opts = %{"phone" => %{"$like" => "%123%"}}
      expected = from(h in FatEcto.FatHospital, where: like(fragment("(?)::TEXT", h.phone), ^"%123%"))
      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignores empty string in where params" do
      opts = %{"name" => %{"$like" => ""}}
      expected = from(h in FatEcto.FatHospital)
      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end
  end
end
