defmodule Query.IncludeTest do
  use FatEcto.ConnCase

  test "returns the query with include associated model" do
    opts = %{
      "$find" => "$all",
      "$include" => %{"fat_hospitals" => %{"$limit" => 3}}
    }

    query = from(h in FatEcto.FatHospital, limit: ^3, offset: ^0)

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [fat_hospitals: ^query]
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

    query = from(h in FatEcto.FatHospital, limit: ^3, offset: ^0)

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.id == ^10 and ^true,
        preload: [fat_hospitals: ^query]
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

    query =
      from(
        h in FatEcto.FatHospital,
        where: h.id == ^10 and ^true,
        order_by: [asc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [fat_hospitals: ^query]
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

    query =
      from(
        h in FatEcto.FatHospital,
        where: h.id == ^10 and ^true,
        order_by: [asc: h.id],
        limit: ^34,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        left_join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
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
      "$where" => %{"name" => "John"}
    }

    query =
      from(
        h in FatEcto.FatHospital,
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        limit: ^34,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John" and ^true,
        right_join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
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
      "$where" => %{"name" => "John"},
      "$order" => %{"id" => "$asc"}
    }

    query =
      from(
        h in FatEcto.FatHospital,
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        limit: ^34,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John" and ^true,
        order_by: [asc: d.id],
        join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
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
      "$where" => %{"name" => "John"}
    }

    query =
      from(
        h in FatEcto.FatHospital,
        where: h.name == ^"Saint" and ^true,
        order_by: [desc: h.id],
        limit: ^34,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John" and ^true,
        full_join: h in assoc(d, :fat_hospitals),
        preload: [fat_hospitals: ^query]
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

    query =
      from(
        h in FatEcto.FatHospital,
        limit: ^34,
        offset: ^0,
        preload: [:fat_rooms]
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [fat_hospitals: ^query]
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

    query =
      from(
        h in FatEcto.FatHospital,
        where: h.name == ^"ham" and ^true,
        limit: ^34,
        offset: ^0,
        preload: [:fat_rooms]
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [fat_hospitals: ^query]
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

    query =
      from(
        h in FatEcto.FatHospital,
        order_by: [desc: h.id],
        limit: ^34,
        offset: ^0,
        preload: [:fat_rooms]
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [fat_hospitals: ^query]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models" do
    opts = %{
      "$include" => %{"fat_hospitals" => %{"$include" => ["fat_rooms", "fat_patients"]}}
    }

    query =
      from(
        h in FatEcto.FatHospital,
        limit: ^34,
        offset: ^0,
        preload: [:fat_patients, :fat_rooms]
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [fat_hospitals: ^query]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models with where" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms", "fat_patients"],
          "$where" => %{"name" => "ham"}
        }
      }
    }

    query =
      from(
        h in FatEcto.FatHospital,
        where: h.name == ^"ham" and ^true,
        limit: ^34,
        offset: ^0,
        preload: [:fat_patients, :fat_rooms]
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [fat_hospitals: ^query]
      )

    result = Query.build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models with order" do
    opts = %{
      "$include" => %{
        "fat_hospitals" => %{
          "$include" => ["fat_rooms", "fat_patients"],
          "$order" => %{"id" => "$asc"}
        }
      }
    }

    query =
      from(
        h in FatEcto.FatHospital,
        order_by: [asc: h.id],
        limit: ^34,
        offset: ^0,
        preload: [:fat_patients, :fat_rooms]
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        preload: [fat_hospitals: ^query]
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
end
