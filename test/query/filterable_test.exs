defmodule Query.FilterableTest do
  use FatEcto.ConnCase

  describe "Filter the params from where_params when params passed in allowed_fields" do
    test "returns the query where field like" do
      opts = %{
        "email" => %{"$like" => "%test%"},
        "phone" => %{"$like" => "%test%"}
      }

      expected =
        from(d in FatEcto.FatDoctor, where: like(fragment("(?)::TEXT", d.email), ^"%test%") and ^true)

      query = DoctorFilter.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query with exact match for field" do
      opts = %{
        "email" => %{"$equal" => "test@test.com"}
      }

      expected = from(d in FatEcto.FatDoctor, where: d.email == ^"test@test.com" and ^true)

      query = DoctorFilter.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query where field ilike" do
      opts = %{
        "email" => %{"$ilike" => "%test%"},
        "phone" => %{"$ilike" => "%test%"}
      }

      expected = from(d in FatEcto.FatDoctor)

      query = DoctorFilter.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignore empty_string when matched with value in ignorables configured" do
      opts = %{
        "email" => %{"$equal" => ""}
      }

      expected = from(d in FatEcto.FatDoctor)

      query = DoctorFilter.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignore %% when matched with value in ignorables configured" do
      opts = %{
        "email" => %{"$like" => "%%"},
        "phone" => %{"$like" => "%test%"}
      }

      expected = from(d in FatEcto.FatDoctor)

      query = DoctorFilter.build(FatEcto.FatDoctor, opts)
      assert inspect(query) == inspect(expected)
    end
  end

  describe "Filter the params from where_params when params passed in not_allowed_fields & allowed_fields empty" do
    test "returns the query where field like" do
      opts = %{
        "name" => %{"$like" => "%test%"},
        "phone" => %{"$like" => "%234%"}
      }

      expected =
        from(h in FatEcto.FatHospital, where: like(fragment("(?)::TEXT", h.phone), ^"%234%") and ^true)

      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignore `nil` when matched with value in ignorables configured" do
      opts = %{
        "name" => %{"$like" => nil},
        "phone" => %{"$like" => nil}
      }

      expected = from(h in FatEcto.FatHospital)

      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query where field with: ilike" do
      opts = %{
        "name" => %{"$like" => "%test%"},
        "phone" => %{"$ilike" => "%234%"}
      }

      expected = from(d in FatEcto.FatHospital)

      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end

    test "return query with exact match on the phone field" do
      opts = %{
        "name" => %{"$like" => "%test%"},
        "phone" => %{"$equal" => "12345"}
      }

      expected = from(h in FatEcto.FatHospital, where: h.phone == ^"12345" and ^true)

      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignore empty_string when matched with value in ignorables configured" do
      opts = %{
        "name" => %{"$like" => "%test%"},
        "phone" => %{"$equal" => ""}
      }

      expected = from(h in FatEcto.FatHospital)

      query = HospitalFilter.build(FatEcto.FatHospital, opts)
      assert inspect(query) == inspect(expected)
    end
  end

  describe "Filter the params from where_params when not_allowed_fields & allowed_fields are empty" do
    test "returns the query where field like" do
      opts = %{
        "name" => %{"$like" => "%marr%"},
        "phone" => %{"$like" => "%234%"}
      }

      expected =
        from(p in FatEcto.FatPatient,
          where:
            like(fragment("(?)::TEXT", p.phone), ^"%234%") and
              (like(fragment("(?)::TEXT", p.name), ^"%marr%") and
                 ^true)
        )

      query = PatientFilter.build(FatEcto.FatPatient, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignore %% when matched with value in ignorables configured" do
      opts = %{
        "name" => %{"$like" => "%%"},
        "phone" => %{"$like" => "%%"}
      }

      expected = from(p in FatEcto.FatPatient)

      query = PatientFilter.build(FatEcto.FatPatient, opts)
      assert inspect(query) == inspect(expected)
    end

    test "returns the query where field exact match" do
      opts = %{
        "name" => %{"$equal" => "st marry"},
        "phone" => %{"$equal" => "12345"}
      }

      expected =
        from(p in FatEcto.FatPatient,
          where:
            p.phone == ^"12345" and
              (p.name == ^"st marry" and
                 ^true)
        )

      query = PatientFilter.build(FatEcto.FatPatient, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignore `nil` && empty_string when matched with value in ignorables configured" do
      opts = %{
        "name" => %{"$equal" => ""},
        "phone" => %{"$equal" => nil}
      }

      expected = from(p in FatEcto.FatPatient)

      query = PatientFilter.build(FatEcto.FatPatient, opts)
      assert inspect(query) == inspect(expected)
    end
  end

  describe "Filter the params from where_params when not_allowed_fields there and override not_allowed_fields_fallback" do
    test "returns the query when name & phone both are in not_allowed fields and custom added to query" do
      opts = %{
        "name" => %{"$like" => "%marr%"},
        "phone" => %{"$ilike" => "%234%"}
      }

      expected =
        from(r in FatEcto.FatRoom,
          where: ilike(fragment("(?)::TEXT", r.phone), ^"%234%"),
          where: like(fragment("(?)::TEXT", r.name), ^"%marr%")
        )

      query = RoomFilter.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignore %% when matched with value in ignorables configured" do
      opts = %{
        "name" => %{"$like" => "%%"},
        "phone" => %{"$ilike" => "%%"}
      }

      expected = from(r in FatEcto.FatRoom)

      query = RoomFilter.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end

    test "ignore %%, `nil` and empty_list [] when matched with value in ignorables configured" do
      opts = %{
        "name" => %{"$like" => "%%"},
        "phone" => %{"$ilike" => "%%"},
        "purpose" => %{"$in" => []},
        "description" => %{"$equal" => nil}
      }

      expected = from(r in FatEcto.FatRoom)

      query = RoomFilter.build(FatEcto.FatRoom, opts)
      assert inspect(query) == inspect(expected)
    end
  end
end
