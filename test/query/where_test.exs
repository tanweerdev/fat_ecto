defmodule Query.WhereTest do
  use FatEcto.ConnCase
  import FatEcto.TestRecordUtils

  setup do
    insert(:doctor)
    insert(:hospital)
    room = insert(:room)
    insert(:bed, fat_room_id: room.id)

    :ok
  end

  test "returns the query where field like" do
    opts = %{
      "$where" => %{"email" => %{"$like" => "%test%"}}
    }

    # expected = from(d in FatEcto.FatDoctor, where: like(d.email, ^"%Joh %"))
    expected = from(d in FatEcto.FatDoctor, where: like(fragment("(?)::TEXT", d.email), ^"%test%") and ^true)

    query = Query.build!(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:start_date, :end_date, :id])

    assert result == %{
             address: "main bulevard",
             designation: "Surgeon",
             email: "test@test.com",
             experience_years: 7,
             name: "John",
             phone: "12345",
             rating: 9
           }
  end

  test "returns the query where field ilike" do
    opts = %{
      "$where" => %{"designation" => %{"$ilike" => "%Surge%"}}
    }

    # expected = from(d in FatEcto.FatDoctor, where: ilike(d.designation, ^"%surge %"))
    expected =
      from(
        d in FatEcto.FatDoctor,
        where: ilike(fragment("(?)::TEXT", d.designation), ^"%Surge%") and ^true
      )

    query = Query.build!(FatEcto.FatDoctor, opts)

    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:start_date, :end_date, :id])

    assert result == %{
             address: "main bulevard",
             designation: "Surgeon",
             email: "test@test.com",
             experience_years: 7,
             name: "John",
             phone: "12345",
             rating: 9
           }
  end

  test "returns the query where field notlike" do
    opts = %{
      "$where" => %{"email" => %{"$not_like" => "%john@%"}}
    }

    # expected = from(d in FatEcto.FatDoctor, where: not like(d.email, ^"%john@ %"))
    expected =
      from(
        d in FatEcto.FatDoctor,
        where: not like(fragment("(?)::TEXT", d.email), ^"%john@%") and ^true
      )

    query = Query.build!(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:start_date, :end_date, :id])

    assert result == %{
             address: "main bulevard",
             designation: "Surgeon",
             email: "test@test.com",
             experience_years: 7,
             name: "John",
             phone: "12345",
             rating: 9
           }
  end

  test "returns the query where field notilike" do
    opts = %{
      "$where" => %{"address" => %{"$not_ilike" => "%street2%"}}
    }

    # expected = from(d in FatEcto.FatDoctor, where: not ilike(d.address, ^"%street2 %"))
    expected =
      from(
        d in FatEcto.FatDoctor,
        where: not ilike(fragment("(?)::TEXT", d.address), ^"%street2%") and ^true
      )

    query = Query.build!(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:start_date, :end_date, :id])

    assert result == %{
             address: "main bulevard",
             designation: "Surgeon",
             email: "test@test.com",
             experience_years: 7,
             name: "John",
             phone: "12345",
             rating: 9
           }
  end

  test "returns the query where field lt" do
    opts = %{
      "$where" => %{"rating" => %{"$lt" => 3}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.rating < ^3 and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field lt another field" do
    opts = %{
      "$where" => %{"total_staff" => %{"$lt" => "$rating"}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.total_staff < h.rating and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:id])

    assert result == %{
             address: "123 street",
             location: "main bullevard",
             name: "st marry",
             phone: "12345",
             rating: 5,
             total_staff: 3
           }
  end

  test "returns the query where field lte" do
    opts = %{
      "$where" => %{"total_staff" => %{"$lte" => 3}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.total_staff <= ^3 and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:id])

    assert result == %{
             address: "123 street",
             location: "main bullevard",
             name: "st marry",
             phone: "12345",
             rating: 5,
             total_staff: 3
           }
  end

  test "returns the query where field not equal" do
    opts = %{
      "$where" => %{"total_staff" => %{"$not_equal" => 3}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.total_staff != ^3 and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result = Repo.one(query)

    assert result == nil
  end

  test "returns the query where field lte another field" do
    opts = %{
      "$where" => %{"rating" => %{"$lte" => "$total_staff"}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.rating <= h.total_staff and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field gt" do
    opts = %{
      "$where" => %{"floor" => %{"$gt" => 3}}
    }

    expected = from(r in FatEcto.FatRoom, where: r.floor > ^3 and ^true)
    query = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field gt another field" do
    opts = %{
      "$where" => %{"rating" => %{"$gt" => "$total_staff"}}
    }

    expected = from(r in FatEcto.FatHospital, where: r.rating > r.total_staff and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:id])

    assert result == %{
             address: "123 street",
             location: "main bullevard",
             name: "st marry",
             phone: "12345",
             rating: 5,
             total_staff: 3
           }
  end

  test "returns the query where field gte" do
    opts = %{
      "$where" => %{"floor" => %{"$gte" => 3}}
    }

    expected = from(r in FatEcto.FatRoom, where: r.floor >= ^3 and ^true)
    query = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:id])

    assert result == %{
             description: "sensitive",
             fat_hospital_id: nil,
             floor: 3,
             is_active: true,
             name: "room 1",
             purpose: "serious patients"
           }
  end

  test "returns the query where field gte another field" do
    opts = %{
      "$where" => %{"rating" => %{"$gte" => "$total_staff"}}
    }

    expected = from(r in FatEcto.FatHospital, where: r.rating >= r.total_staff and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:id])

    assert result == %{
             address: "123 street",
             location: "main bullevard",
             name: "st marry",
             phone: "12345",
             rating: 5,
             total_staff: 3
           }
  end

  test "returns the query where field between" do
    opts = %{
      "$where" => %{"total_staff" => %{"$between" => [10, 20]}}
    }

    expected = from(r in FatEcto.FatHospital, where: r.total_staff > ^10 and r.total_staff < ^20 and ^true)

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field between equal" do
    opts = %{
      "$where" => %{"total_staff" => %{"$between_equal" => [10, 20]}}
    }

    expected = from(r in FatEcto.FatHospital, where: r.total_staff >= ^10 and r.total_staff <= ^20 and ^true)

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field notbetween" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_between" => [10, 20]}}
    }

    expected =
      from(
        p in FatEcto.FatPatient,
        where: (p.appointments_count < ^10 or p.appointments_count > ^20) and ^true
      )

    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field notbetween blacklisted" do
    opts = %{
      "$where" => %{"date_of_birth" => %{"$not_between" => [10, 20]}}
    }

    query = Query.build!(FatEcto.FatPatient, opts)

    expected =
      from(
        p in FatEcto.FatPatient,
        where: (p.date_of_birth < ^10 or p.date_of_birth > ^20) and ^true
      )

    assert inspect(query) == inspect(expected)
  end

  test "returns the query where field notbetween equal" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_between_equal" => [10, 20]}}
    }

    expected =
      from(
        p in FatEcto.FatPatient,
        where: (p.appointments_count <= ^10 or p.appointments_count >= ^20) and ^true
      )

    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field in" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$in" => [4]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count in ^[4] and ^true)
    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field notin" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_in" => [20, 50]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count not in ^[20, 50] and ^true)
    query = Query.build!(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field isnil" do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234"})

    opts = %{
      "$where" => %{"rating" => nil}
    }

    expected = from(h in FatEcto.FatHospital, where: is_nil(h.rating) and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:id])

    assert result == %{
             address: nil,
             location: nil,
             name: "Doe",
             phone: "1234",
             rating: nil,
             total_staff: nil
           }
  end

  test "returns the query where field not isnil" do
    opts = %{
      "$where" => %{"$not_null" => ["rating"]}
    }

    expected = from(h in FatEcto.FatHospital, where: not is_nil(h.rating) and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:id])

    assert result == %{
             address: "123 street",
             location: "main bullevard",
             name: "st marry",
             phone: "12345",
             rating: 5,
             total_staff: 3
           }
  end

  test "returns the query where field is binary" do
    opts = %{
      "$where" => %{"location" => "main bullevard"}
    }

    expected = from(h in FatEcto.FatHospital, where: h.location == ^"main bullevard" and ^true)
    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.one()
      |> sanitize()
      |> Map.drop([:id])

    assert result == %{
             address: "123 street",
             location: "main bullevard",
             name: "st marry",
             phone: "12345",
             rating: 5,
             total_staff: 3
           }
  end

  test "returns query where field is binary" do
    opts = %{
      "$where" => %{"phone" => "1234567"}
    }

    query = Query.build!(FatEcto.FatHospital, opts)

    expected =
      from(f0 in FatEcto.FatHospital,
        where: f0.phone == ^"1234567" and ^true
      )

    assert inspect(query) == inspect(expected)
  end

  test "returns the query with or fields" do
    insert(:hospital, name: "DJ", location: "main bullevard")
    insert(:hospital, name: "Johnson", location: "main bullevard")

    opts = %{
      "$where" => %{
        "name" => %{"$not_ilike" => "%DJ%"},
        "$or" => %{
          "location" => %{"$like" => "%main%"},
          "address" => %{"$ilike" => "%123%"},
          "rating" => %{"$lt" => 3},
          "total_staff" => %{"$gt" => 2}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff > ^2 or
            (f0.rating < ^3 or
               (like(fragment("(?)::TEXT", f0.location), ^"%main%") or
                  (ilike(fragment("(?)::TEXT", f0.address), ^"%123%") or ^false))),
        where: not ilike(fragment("(?)::TEXT", f0.name), ^"%DJ%") and ^true
      )

    query = Query.build!(FatEcto.FatHospital, opts)

    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "st marry",
               phone: "12345",
               rating: 5,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Johnson",
               phone: "12345",
               rating: 5,
               total_staff: 3
             }
           ]
  end

  test "returns the query with or/and fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 2)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 3)

    opts = %{
      "$where" => %{
        "name" => %{"$like" => "%Joh%"},
        "rating" => %{"$in" => [2, 3]},
        "$or" => %{
          "total_staff" => %{"$gte" => 2}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where: f0.total_staff >= ^2 or ^false,
        where: f0.rating in ^[2, 3] and (like(fragment("(?)::TEXT", f0.name), ^"%Joh%") and ^true)
      )

    query = Query.build!(FatEcto.FatHospital, opts)

    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Johnson",
               phone: "12345",
               rating: 3,
               total_staff: 3
             }
           ]
  end

  test "returns the query only with or fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard", total_staff: 6)
    insert(:hospital, name: "Johnson", location: "main bullevard", total_staff: 6)

    opts = %{
      "$where" => %{
        "$or" => %{
          "name" => %{"$like" => "%Joh%"},
          "total_staff" => %{"$between_equal" => [5, 7]}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          (f0.total_staff >= ^5 and f0.total_staff <= ^7) or
            (like(fragment("(?)::TEXT", f0.name), ^"%Joh%") or ^false)
      )

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Belarus",
               phone: "12345",
               rating: 5,
               total_staff: 6
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Johnson",
               phone: "12345",
               rating: 5,
               total_staff: 6
             }
           ]
  end

  test "returns the query with and/ or not between fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 4)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 5)

    opts = %{
      "$where" => %{
        "name" => %{"$like" => "%Joh%"},
        "location" => %{"$ilike" => "%main%"},
        "$or" => %{
          "rating" => %{"$not_between" => [2, 3]},
          "total_staff" => %{"$not_between_equal" => [1, 4]}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where: f0.total_staff <= ^1 or f0.total_staff >= ^4 or (f0.rating < ^2 or f0.rating > ^3 or ^false),
        where:
          like(fragment("(?)::TEXT", f0.name), ^"%Joh%") and
            (ilike(fragment("(?)::TEXT", f0.location), ^"%main%") and ^true)
      )

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Johnson",
               phone: "12345",
               rating: 5,
               total_staff: 3
             }
           ]
  end

  test "returns the query with and/ or in fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard")
    insert(:hospital, name: "Johnson", location: "main bullevard")

    opts = %{
      "$where" => %{
        "location" => %{"$ilike" => "%main%"},
        "$or" => %{
          "name" => %{"$ilike" => "%Joh%"},
          "rating" => %{"$in" => [2, 3]},
          "total_staff" => %{"$not_in" => [1, 4]}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff not in ^[1, 4] or
            (f0.rating in ^[2, 3] or (ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or ^false)),
        where: ilike(fragment("(?)::TEXT", f0.location), ^"%main%") and ^true
      )

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "st marry",
               phone: "12345",
               rating: 5,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Belarus",
               phone: "12345",
               rating: 5,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Johnson",
               phone: "12345",
               rating: 5,
               total_staff: 3
             }
           ]
  end

  test "returns the query with and/ or not like/ilike/equal fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 2)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 3)

    opts = %{
      "$where" => %{
        "$or" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false)))
      )

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "st marry",
               phone: "12345",
               rating: 5,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Belarus",
               phone: "12345",
               rating: 2,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Johnson",
               phone: "12345",
               rating: 3,
               total_staff: 3
             }
           ]
  end

  test "returns the query with two or not like/ilike/equal fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 2)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 3)

    opts = %{
      "$where" => %{
        "$or" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]}
        },
        "$or_1" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false)))
      )

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "st marry",
               phone: "12345",
               rating: 5,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Belarus",
               phone: "12345",
               rating: 2,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Johnson",
               phone: "12345",
               rating: 3,
               total_staff: 3
             }
           ]
  end

  test "returns the query with nil, eq fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 2)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 3)

    opts = %{
      "$where" => %{
        "$or" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => nil
        },
        "$or_1" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$not_equal" => 2},
          "rating" => 2
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff == ^2 or
            (is_nil(f0.rating) or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          f0.total_staff != ^2 or
            (f0.rating == ^2 or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false)))
      )

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
  end

  test "returns the query with and/two or not like/ilike/equal fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 2)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 3)

    opts = %{
      "$where" => %{
        "name" => %{"$not_ilike" => "%Joh%"},
        "location" => %{"$not_like" => "%some%"},
        "$or" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]}
        },
        "$or_1" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") and
            (not like(fragment("(?)::TEXT", f0.location), ^"%some%") and ^true)
      )

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "st marry",
               phone: "12345",
               rating: 5,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Belarus",
               phone: "12345",
               rating: 2,
               total_staff: 3
             }
           ]
  end

  test "returns the query with and/three or not like/ilike/equal fields" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 2)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 3)

    opts = %{
      "$where" => %{
        "name" => %{"$not_ilike" => "%Joh%"},
        "location" => %{"$not_like" => "%some%"},
        "$or" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]}
        },
        "$or_1" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]}
        },
        "$or_2" => %{
          "name" => %{"$ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$between" => [2, 6]},
          "rating" => %{"$not_in" => [2, 3]}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          (f0.total_staff > ^2 and f0.total_staff < ^6) or
            (f0.rating not in ^[2, 3] or
               (ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") and
            (not like(fragment("(?)::TEXT", f0.location), ^"%some%") and ^true)
      )

    query = Query.build!(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      query
      |> Repo.all()
      |> sanitize()
      |> Enum.map(fn record -> Map.drop(record, [:id]) end)

    assert result == [
             %{
               address: "123 street",
               location: "main bullevard",
               name: "st marry",
               phone: "12345",
               rating: 5,
               total_staff: 3
             },
             %{
               address: "123 street",
               location: "main bullevard",
               name: "Belarus",
               phone: "12345",
               rating: 2,
               total_staff: 3
             }
           ]
  end

  test "returns the query with and/three or not like/ilike/equal fields with blacklist params" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 2)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 3)

    opts = %{
      "$where" => %{
        "name" => %{"$not_ilike" => "%Joh%"},
        "location" => %{"$not_like" => "%some%"},
        "$or" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]},
          "phone" => "0071566025410"
        },
        "$or_1" => %{
          "name" => %{"$not_ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$equal" => 2},
          "rating" => %{"$in" => [2, 3]}
        },
        "$or_2" => %{
          "name" => %{"$ilike" => "%Joh%"},
          "location" => %{"$not_like" => "%some%"},
          "total_staff" => %{"$between" => [2, 6]},
          "rating" => %{"$not_in" => [2, 3]}
        }
      }
    }

    query = Query.build!(FatEcto.FatHospital, opts)

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (f0.phone == ^"0071566025410" or
                  (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                     (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false)))),
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          (f0.total_staff > ^2 and f0.total_staff < ^6) or
            (f0.rating not in ^[2, 3] or
               (ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^false))),
        where:
          not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") and
            (not like(fragment("(?)::TEXT", f0.location), ^"%some%") and ^true)
      )

    assert inspect(expected) == inspect(query)
  end

  test "paginator with primary key id" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_in" => [20, 50]}, "name" => "john"}
    }

    paginator =
      FatEcto.FatPatient
      |> Query.build!(opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected =
      from(p in FatEcto.FatPatient,
        where: p.name == ^"john" and (p.appointments_count not in ^[20, 50] and ^true),
        distinct: true
      )

    assert inspect(expected) == inspect(count_query)

    opts = %{
      "$where" => %{"floor" => %{"$not_in" => [20, 50]}, "name" => "ICU"}
    }

    paginator =
      FatEcto.FatRoom
      |> Query.build!(opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected =
      from(r in FatEcto.FatRoom,
        where: r.name == ^"ICU" and (r.floor not in ^[20, 50] and ^true),
        distinct: true
      )

    assert inspect(expected) == inspect(count_query)
  end

  test "paginator with composite primary key" do
    opts = %{
      "$where" => %{"fat_doctor_id" => 1}
    }

    paginator =
      FatEcto.FatHospitalDoctor
      |> Query.build!(opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected =
      from(d in FatEcto.FatHospitalDoctor,
        where: d.fat_doctor_id == ^1 and ^true,
        select: fragment("COUNT(DISTINCT ROW(?, ?))::int", d.fat_doctor_id, d.fat_hospital_id),
        distinct: true
      )

    assert inspect(expected) == inspect(count_query)

    opts = %{
      "$where" => %{"fat_patient_id" => 10}
    }

    paginator =
      "fat_doctors_patients"
      |> Query.build!(opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected =
      from(d in "fat_doctors_patients",
        where: d.fat_patient_id == ^10 and ^true,
        select: count("*"),
        distinct: true
      )

    assert inspect(expected) == inspect(count_query)
  end

  test "paginator with table name and single primary key" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_in" => [20, 50]}, "name" => "john"}
    }

    paginator =
      "fat_patients"
      |> Query.build!(opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected =
      from(p in "fat_patients",
        where: p.name == ^"john" and (p.appointments_count not in ^[20, 50] and ^true),
        distinct: true,
        select: count("*")
      )

    assert inspect(expected) == inspect(count_query)
  end

  test "test dynamics with different data structures" do
    insert(:hospital, name: "Belarus", location: "main bullevard", rating: 2)
    insert(:hospital, name: "Johnson", location: "main bullevard", rating: 3)

    opts = %{
      "$where" => %{
        "name" => "%Joh%",
        "location" => nil,
        "$not_null" => ["total_staff", "address", "phone"],
        "rating" => "$not_null",
        "total_staff" => %{"$between" => [1, 3]}
      }
    }

    expected =
      from(f0 in FatEcto.FatHospital,
        where:
          f0.total_staff > ^1 and f0.total_staff < ^3 and
            (not is_nil(f0.rating) and
               (f0.name == ^"%Joh%" and
                  (is_nil(f0.location) and
                     (not is_nil(f0.phone) and
                        (not is_nil(f0.address) and (not is_nil(f0.total_staff) and ^true))))))
      )

    assert inspect(Query.build!(FatEcto.FatHospital, opts)) == inspect(expected)
  end

  test "failing example for using == for DateTime values" do
    now = DateTime.utc_now()

    opts = %{
      "$where" => %{
        "start_date" => %{"$equal" => now}
      }
    }

    expected =
      from(f0 in FatEcto.FatDoctor,
        where: f0.start_date == ^now and ^true
      )

    assert inspect(Query.build!(FatEcto.FatDoctor, opts)) == inspect(expected)
  end
end
