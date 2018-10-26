defmodule Query.IncludeTest do
  use ExUnit.Case
  import FatEcto.FatQuery
  import Ecto.Query

  test "returns the query with include associated model" do
    opts = %{
      "$find" => "$all",
      "$include" => %{"hospitals" => %{"$limit" => 3}}
    }

    query = from(h in FatEcto.FatHospital, limit: ^3, offset: ^0)

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and where" do
    opts = %{
      "$find" => "$all",
      "$include" => %{"hospitals" => %{"$limit" => 3}},
      "$where" => %{"id" => 10}
    }

    query = from(h in FatEcto.FatHospital, limit: ^3, offset: ^0)

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.id == ^10,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and where and order" do
    opts = %{
      "$include" => %{
        "hospitals" => %{
          "$limit" => 10,
          "$order" => %{"id" => "$asc"},
          "$where" => %{"id" => 10}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.id == ^10,
        order_by: [asc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and left join" do
    opts = %{
      "$include" => %{
        "hospitals" => %{
          "$join" => "$left",
          "$order" => %{"id" => "$asc"},
          "$where" => %{"id" => 10}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.id == ^10,
        order_by: [asc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        left_join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and right join" do
    opts = %{
      "$include" => %{
        "hospitals" => %{
          "$join" => "$right",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"name" => "John"}
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.name == ^"Saint",
        order_by: [desc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John",
        right_join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and inner join" do
    opts = %{
      "$include" => %{
        "hospitals" => %{
          "$join" => "$inner",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"name" => "John"},
      "$order" => %{"id" => "$asc"}
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.name == ^"Saint",
        order_by: [desc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John",
        order_by: [asc: d.id],
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include associated model and full join" do
    opts = %{
      "$include" => %{
        "hospitals" => %{
          "$join" => "$full",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      },
      "$where" => %{"name" => "John"}
    }

    query =
      from(h in FatEcto.FatHospital,
        where: h.name == ^"Saint",
        order_by: [desc: h.id],
        limit: ^10,
        offset: ^0
      )

    expected =
      from(
        d in FatEcto.FatDoctor,
        where: d.name == ^"John",
        full_join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include as a binary" do
    opts = %{
      "$include" => "hospitals"
    }

    expected =
      from(
        d in FatEcto.FatDoctor,
        left_join: h in assoc(d, :hospitals),
        preload: [:hospitals]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include" do
    opts = %{
      "$include" => %{"hospitals" => %{"$include" => ["rooms"]}}
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :rooms),
        limit: ^10,
        offset: ^0,
        preload: [:rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include and where" do
    opts = %{
      "$include" => %{
        "hospitals" => %{
          "$include" => ["rooms"],
          "$where" => %{"name" => "ham"}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :rooms),
        where: h.name == ^"ham",
        limit: ^10,
        offset: ^0,
        preload: [:rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include and order" do
    opts = %{
      "$include" => %{
        "hospitals" => %{
          "$include" => ["rooms"],
          "$order" => %{"id" => "$desc"}
        }
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :rooms),
        order_by: [desc: h.id],
        limit: ^10,
        offset: ^0,
        preload: [:rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models" do
    opts = %{
      "$include" => %{"hospitals" => %{"$include" => ["rooms", "patients"]}}
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :rooms),
        left_join: p in assoc(h, :patients),
        limit: ^10,
        offset: ^0,
        preload: [:patients, :rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models with where" do
    opts = %{
      "$include" => %{
        "hospitals" => %{"$include" => ["rooms", "patients"], "$where" => %{"name" => "ham"}}
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :rooms),
        left_join: p in assoc(h, :patients),
        where: h.name == ^"ham",
        limit: ^10,
        offset: ^0,
        preload: [:patients, :rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with nested include models with order" do
    opts = %{
      "$include" => %{
        "hospitals" => %{"$include" => ["rooms", "patients"], "$order" => %{"id" => "$asc"}}
      }
    }

    query =
      from(h in FatEcto.FatHospital,
        left_join: r in assoc(h, :rooms),
        order_by: [asc: h.id],
        left_join: p in assoc(h, :patients),
        limit: ^10,
        offset: ^0,
        preload: [:patients, :rooms]
      )

    expected =
      from(d in FatEcto.FatDoctor,
        join: h in assoc(d, :hospitals),
        preload: [hospitals: ^query]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with include list" do
    opts = %{
      "$include" => ["hospitals", "patients"]
    }

    expected =
      from(d in FatEcto.FatDoctor,
        left_join: h in assoc(d, :hospitals),
        left_join: p in assoc(d, :patients),
        preload: [:patients, :hospitals]
      )

    result = build(FatEcto.FatDoctor, opts)
    assert inspect(result) == inspect(expected)
  end
end
