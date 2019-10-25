defmodule Query.WhereTest do
  use FatEcto.ConnCase
  import FatEcto.TestRecordUtils

  setup do
    insert(:doctor)
    insert(:hospital)
    room = insert(:room)
    insert(:bed, fat_room_id: room.id)
    Application.delete_env(:fat_ecto, :fat_ecto, [:blacklist_params])

    :ok
  end

  test "returns the query where field like" do
    opts = %{
      "$where" => %{"email" => %{"$like" => "%test%"}}
    }

    # expected = from(d in FatEcto.FatDoctor, where: like(d.email, ^"%Joh %"))
    expected = from(d in FatEcto.FatDoctor, where: like(fragment("(?)::TEXT", d.email), ^"%test%") and ^true)

    query = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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

    query = Query.build(FatEcto.FatDoctor, opts)

    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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

    query = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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

    query = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field lt another field" do
    opts = %{
      "$where" => %{"total_staff" => %{"$lt" => "$rating"}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.total_staff < h.rating and ^true)
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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

  test "returns the query where field lte another field" do
    opts = %{
      "$where" => %{"rating" => %{"$lte" => "$total_staff"}}
    }

    expected = from(h in FatEcto.FatHospital, where: h.rating <= h.total_staff and ^true)
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field gt" do
    opts = %{
      "$where" => %{"floor" => %{"$gt" => 3}}
    }

    expected = from(r in FatEcto.FatRoom, where: r.floor > ^3 and ^true)
    query = Query.build(FatEcto.FatRoom, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field gt another field" do
    opts = %{
      "$where" => %{"rating" => %{"$gt" => "$total_staff"}}
    }

    expected = from(r in FatEcto.FatHospital, where: r.rating > r.total_staff and ^true)
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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
    query = Query.build(FatEcto.FatRoom, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field between equal" do
    opts = %{
      "$where" => %{"total_staff" => %{"$between_equal" => [10, 20]}}
    }

    expected = from(r in FatEcto.FatHospital, where: r.total_staff >= ^10 and r.total_staff <= ^20 and ^true)

    query = Query.build(FatEcto.FatHospital, opts)
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

    query = Query.build(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field notbetween blacklisted" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_hospitals, ["some", "total_staff"]}, {:fat_patients, ["appointments_count"]}]
    )

    opts = %{
      "$where" => %{"date_of_birth" => %{"$not_between" => [10, 20]}}
    }

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatPatient, opts) end
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

    query = Query.build(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field in" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$in" => [4]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count in ^[4] and ^true)
    query = Query.build(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field notin" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_in" => [20, 50]}}
    }

    expected = from(p in FatEcto.FatPatient, where: p.appointments_count not in ^[20, 50] and ^true)
    query = Query.build(FatEcto.FatPatient, opts)
    assert inspect(query) == inspect(expected)
    assert Repo.one(query) == nil
  end

  test "returns the query where field isnil" do
    Repo.insert(%FatEcto.FatHospital{name: "Doe", phone: "1234"})

    opts = %{
      "$where" => %{"rating" => nil}
    }

    expected = from(h in FatEcto.FatHospital, where: is_nil(h.rating) and ^true)
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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
    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.one(query)
      |> sanitize_map()
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

  test "returns the query where field is binary and blacklisted" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_hospitals, ["location"]}, {:fat_beds, ["is_active"]}]
    )

    opts = %{
      "$where" => %{"phone" => "1234567"}
    }

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatHospital, opts) end
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
                  (ilike(fragment("(?)::TEXT", f0.address), ^"%123%") or ^true))),
        where: not ilike(fragment("(?)::TEXT", f0.name), ^"%DJ%") and ^true
      )

    query = Query.build(FatEcto.FatHospital, opts)

    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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
        where: f0.total_staff >= ^2 or ^true,
        where: like(fragment("(?)::TEXT", f0.name), ^"%Joh%") and ^true,
        where: f0.rating in ^[2, 3] and ^true
      )

    query = Query.build(FatEcto.FatHospital, opts)

    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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
            (like(fragment("(?)::TEXT", f0.name), ^"%Joh%") or ^true)
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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
        where: f0.total_staff <= ^1 or f0.total_staff >= ^4 or (f0.rating < ^2 or f0.rating > ^3 or ^true),
        where: ilike(fragment("(?)::TEXT", f0.location), ^"%main%") and ^true,
        where: like(fragment("(?)::TEXT", f0.name), ^"%Joh%") and ^true
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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
            (f0.rating in ^[2, 3] or (ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or ^true)),
        where: ilike(fragment("(?)::TEXT", f0.location), ^"%main%") and ^true
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^true)))
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^true))),
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^true)))
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^true))),
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^true))),
        where: not like(fragment("(?)::TEXT", f0.location), ^"%some%") and ^true,
        where: not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") and ^true
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^true))),
        where:
          f0.total_staff == ^2 or
            (f0.rating in ^[2, 3] or
               (not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^true))),
        where:
          (f0.total_staff > ^2 and f0.total_staff < ^6) or
            (f0.rating not in ^[2, 3] or
               (ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") or
                  (not like(fragment("(?)::TEXT", f0.location), ^"%some%") or ^true))),
        where: not like(fragment("(?)::TEXT", f0.location), ^"%some%") and ^true,
        where: not ilike(fragment("(?)::TEXT", f0.name), ^"%Joh%") and ^true
      )

    query = Query.build(FatEcto.FatHospital, opts)
    assert inspect(query) == inspect(expected)

    result =
      Repo.all(query)
      |> sanitize_map()
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

    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_hospitals, ["some", "total_staff"]}, {:fat_beds, ["is_active"]}]
    )

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

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatHospital, opts) end
  end

  test "paginator with primary key id" do
    opts = %{
      "$where" => %{"appointments_count" => %{"$not_in" => [20, 50]}, "name" => "john"}
    }

    paginator =
      Query.build(FatEcto.FatPatient, opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected =
      from(p in FatEcto.FatPatient,
        where: p.appointments_count not in ^[20, 50] and ^true,
        where: p.name == ^"john" and ^true
      )

    assert inspect(expected) == inspect(count_query)

    opts = %{
      "$where" => %{"floor" => %{"$not_in" => [20, 50]}, "name" => "ICU"}
    }

    paginator =
      Query.build(FatEcto.FatRoom, opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected =
      from(r in FatEcto.FatRoom, where: r.floor not in ^[20, 50] and ^true, where: r.name == ^"ICU" and ^true)

    assert inspect(expected) == inspect(count_query)
  end

  test "paginator with composite primary key" do
    opts = %{
      "$where" => %{"fat_doctor_id" => 1}
    }

    paginator =
      Query.build(FatEcto.FatHospitalDoctor, opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected =
      from(d in FatEcto.FatHospitalDoctor, where: d.fat_doctor_id == ^1 and ^true, select: count("*"))

    assert inspect(expected) == inspect(count_query)

    opts = %{
      "$where" => %{"fat_patient_id" => 10}
    }

    paginator =
      Query.build("fat_doctors_patients", opts)
      |> Query.paginate(skip: 0, limit: 10)

    %{count_query: count_query} = paginator

    expected = from(d in "fat_doctors_patients", where: d.fat_patient_id == ^10 and ^true, select: count("*"))

    assert inspect(expected) == inspect(count_query)
  end
end
