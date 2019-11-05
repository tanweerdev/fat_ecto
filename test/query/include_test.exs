defmodule Query.IncludeTest do
  use FatEcto.ConnCase

  setup do
    Application.delete_env(:fat_ecto, :fat_ecto, [:blacklist_params])

    :ok
  end

  test "returns the query with include associated model" do
    opts = %{
      "$find" => "$all",
      "$include" => %{"fat_hospitals" => %{"$limit" => 3}}
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: f in assoc(d, :fat_hospitals),
        preload: [^[:fat_hospitals]],
        limit: ^3,
        offset: ^0
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and where" do
    opts = %{
      "$find" => "$all",
      "$include" => %{"fat_hospitals" => %{"$limit" => 3}},
      "$where" => %{"id" => 10}
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.id == ^10 and ^true,
        join: f in assoc(d, :fat_hospitals),
        preload: [^[:fat_hospitals]],
        limit: ^3,
        offset: ^0
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and where and order" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$limit" => 10,
          "$order" => %{"id" => "$asc"},
          "$where" => %{"id" => 10}
        }
      }
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: f in assoc(d, :fat_hospitals),
        where: f.id == ^10 and ^true,
        order_by: [asc: f.id],
        preload: [^[:fat_hospitals]],
        limit: ^10,
        offset: ^0
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and left join" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$join" => "$left",
          "$order" => %{"id" => "$asc"},
          "$where" => %{"id" => 10}
        }
      }
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        left_join: f in assoc(d, :fat_hospitals),
        where: f.id == ^10 and ^true,
        order_by: [asc: f.id],
        preload: [^[:fat_hospitals]],
        limit: ^34,
        offset: ^0
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and right join" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$join" => "$right",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"email" => "John"}
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.email == ^"John" and ^true,
        right_join: h in assoc(d, :fat_hospitals),
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        preload: [^[:fat_hospitals]],
        limit: ^34,
        offset: ^0
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and inner join" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$join" => "$inner",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"email" => "John"},
      "$order" => %{"id" => "$asc"}
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.email == ^"John" and ^true,
        join: h in assoc(d, :fat_hospitals),
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        order_by: [asc: d.id],
        preload: [^[:fat_hospitals]],
        limit: ^34,
        offset: ^0
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and full join" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$join" => "$full",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"email" => "John"}
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.email == ^"John" and ^true,
        full_join: h in assoc(d, :fat_hospitals),
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        preload: [^[:fat_hospitals]],
        limit: ^34,
        offset: ^0
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include as a binary" do
    opts = %{
      "$include" => "fat_hospitals"
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [:fat_hospitals]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include" do
    opts = %{
      "$include" => %{"fat_hospitals" => %{"$include" => ["fat_rooms"]}}
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        limit: ^34,
        offset: ^0,
        preload: ^[{:fat_hospitals, [:fat_rooms]}]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include and where" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms"],
          "$where" => %{"name" => "ham"}
        }
      }
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        where: h.name == ^"ham" and ^true,
        preload: ^[{:fat_hospitals, [:fat_rooms]}],
        limit: ^34,
        offset: ^0
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include and order" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms"],
          "$order" => %{"id" => "$desc"}
        }
      }
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        order_by: [desc: h.id],
        limit: ^34,
        offset: ^0,
        preload: ^[{:fat_hospitals, [:fat_rooms]}]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include and order blacklisted" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["name", "nurses"]}, {:fat_hospitals, ["id"]}]
    )

    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms"],
          "$order" => %{"phone" => "$desc"}
        }
      }
    }

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatDoctor, opts) end
  end

  test "returns the query with nested include and group_by blacklisted" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["name", "nurses"]}, {:fat_hospitals, ["name"]}]
    )

    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms"],
          "$order" => %{"id" => "$desc"},
          "$group" => "phone"
        }
      }
    }

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatDoctor, opts) end
  end

  test "returns the query with nested include models" do
    opts = %{
      "$include" => %{"fat_hospitals" => %{"$include" => "fat_rooms"}}
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        limit: ^34,
        offset: ^0,
        preload: ^[{:fat_hospitals, :fat_rooms}]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models with where" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_patients"],
          "$where" => %{"name" => "ham"}
        }
      }
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        where: h.name == ^"ham" and ^true,
        limit: ^34,
        offset: ^0,
        preload: ^[{:fat_hospitals, [:fat_patients]}]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models with where and blacklist attributes" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["name", "nurses"]}, {:fat_hospitals, ["name"]}]
    )

    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms", "fat_patients"],
          "$where" => %{"phone" => "ham"}
        }
      }
    }

    assert_raise ArgumentError, fn -> Query.build(FatEcto.FatDoctor, opts) end
  end

  test "returns the query with nested include models with order" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms"],
          "$order" => %{"id" => "$asc"}
        }
      }
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :fat_hospitals),
        order_by: [asc: h.id],
        limit: ^34,
        offset: ^0,
        preload: ^[{:fat_hospitals, [:fat_rooms]}]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include list" do
    opts = %{
      "$include" => ["fat_hospitals", "fat_patients"]
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [:fat_patients, :fat_hospitals]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include maps" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{"$include" => %{"fat_rooms" => %{}}},
        "fat_patients" => %{"$include" => %{"fat_doctors" => %{}}}
      }
    }

    expected =
      from(f0 in FatEcto.FatDoctor,
        join: f1 in assoc(f0, :fat_hospitals),
        join: f2 in assoc(f1, :fat_rooms),
        join: f3 in assoc(f0, :fat_patients),
        join: f4 in assoc(f3, :fat_doctors),
        limit: ^34,
        offset: ^0,
        preload: [^[fat_patients: [:fat_doctors], fat_hospitals: [:fat_rooms]]]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with deeply nested include maps,list and string" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{"$include" => %{"fat_rooms" => %{"$include" => ["fat_hospital", "fat_beds"]}}},
        "fat_patients" => %{
          "$include" => %{
            "fat_doctors" => %{
              "$include" => %{"fat_hospitals" => %{"$include" => "fat_rooms", "$where" => %{"name" => "Joh"}}}
            }
          }
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatDoctor,
        join: f1 in assoc(f0, :fat_hospitals),
        join: f2 in assoc(f1, :fat_rooms),
        join: f3 in assoc(f0, :fat_patients),
        join: f4 in assoc(f3, :fat_doctors),
        join: f5 in assoc(f4, :fat_hospitals),
        where: f5.name == ^"Joh" and ^true,
        limit: ^34,
        offset: ^0,
        preload: [
          ^[
            fat_patients: [fat_doctors: [fat_hospitals: :fat_rooms]],
            fat_hospitals: [fat_rooms: [:fat_hospital, :fat_beds]]
          ]
        ]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include maps" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{},
        "fat_patients" => %{}
      }
    }

    expected =
      from(f0 in FatEcto.FatDoctor,
        join: f1 in assoc(f0, :fat_hospitals),
        join: f2 in assoc(f0, :fat_patients),
        limit: ^34,
        offset: ^0,
        preload: [^[:fat_patients, :fat_hospitals]]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end
end
