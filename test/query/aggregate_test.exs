defmodule Query.AggregateTest do
  use FatEcto.ConnCase

  setup do
    insert(:room)
    insert(:room)
    Application.delete_env(:fat_ecto, :fat_ecto, [:blacklist_params])

    :ok
  end

  test "returns the query with aggregate count" do
    opts = %{
      "$select" => ["name", "purpose"],
      "$aggregate" => %{"$count" => "id"},
      "$where" => %{"floor" => %{"$gt" => 2}},
      "$group" => ["id"]
    }

    expected =
      from(fr in FatEcto.FatRoom,
        where: fr.floor > ^2 and ^true,
        group_by: [fr.id],
        select: merge(map(fr, [:name, :purpose]), %{"$aggregate" => %{"$count": %{^"id" => count(fr.id)}}})
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
    # TODO: match on records returned
    Repo.all(result)

    opts = %{
      "$aggregate" => %{"$count" => "id"},
      "$where" => %{"floor" => %{"$gt" => 2}},
      "$group" => ["id"]
    }

    expected =
      from(fr in FatEcto.FatRoom,
        where: fr.floor > ^2 and ^true,
        group_by: [fr.id],
        select:
          merge(
            fr,
            %{"$aggregate" => %{"$count": %{^"id" => count(fr.id)}}}
          )
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)

    # NOTE: this will fail and will work when you provide $select
    assert_raise ArgumentError, fn ->
      Repo.all(result)
    end
  end

  test "returns the query with aggregate distinct count" do
    opts = %{
      "$aggregate" => %{"$count_distinct" => "nurses"},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$desc"}
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        order_by: [desc: f0.beds],
        select:
          merge(f0, %{"$aggregate" => %{"$count_distinct": %{^"nurses" => count(f0.nurses, :distinct)}}})
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate min" do
    opts = %{
      "$aggregate" => %{"$min" => "nurses"},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$desc"},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        order_by: [desc: f0.beds],
        select: merge(f0, %{"$aggregate" => %{"$min": %{^"nurses" => min(f0.nurses)}}})
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate max" do
    opts = %{
      "$aggregate" => %{"$max" => "nurses"},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select: merge(f0, %{"$aggregate" => %{"$max": %{^"nurses" => max(f0.nurses)}}})
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate sum" do
    opts = %{
      "$aggregate" => %{"$sum" => "nurses"},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$asc"},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        order_by: [asc: f0.beds],
        select: merge(f0, %{"$aggregate" => %{"$sum": %{^"nurses" => sum(f0.nurses)}}})
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate average" do
    opts = %{
      "$aggregate" => %{"$avg" => "level"},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$asc"},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        order_by: [asc: f0.beds],
        select: merge(f0, %{"$aggregate" => %{"$avg": %{^"level" => avg(f0.level)}}})
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate average/include" do
    opts = %{
      "$aggregate" => %{"$avg" => "level"},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$asc"},
      "$group" => "capacity",
      "$include" => %{
        "fat_hospital" => %{
          "$join" => "$full",
          "$order" => %{"id" => "$desc"},
          "$where" => %{"name" => "Saint"}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        full_join: f1 in assoc(f0, :fat_hospital),
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select: merge(f0, %{"$aggregate" => %{"$avg": %{^"level" => avg(f0.level)}}}),
        where: f1.name == ^"Saint" and ^true,
        order_by: [desc: f1.id],
        order_by: [asc: f0.beds],
        preload: [:fat_hospital],
        limit: ^34,
        offset: ^0
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate sum/join" do
    opts = %{
      "$aggregate" => %{"$sum" => "level"},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$asc"},
      "$group" => "capacity",
      "$right_join" => %{
        "fat_hospital" => %{
          "$on_field" => "hospital_id",
          "$on_table_field" => "id",
          "$select" => ["name", "location", "phone"],
          "$where" => %{"address" => "street 2"}
        }
      }
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        right_join: f1 in "fat_hospital",
        on: f0.hospital_id == f1.id,
        where: f0.capacity == ^5 and ^true,
        where: f1.address == ^"street 2" and ^true,
        group_by: [f0.capacity],
        order_by: [asc: f0.beds],
        select:
          merge(%{^"fat_hospital" => map(f1, [:name, :location, :phone])}, %{
            "$aggregate" => %{"$sum": %{^"level" => sum(f0.level)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  @tag :incorrect
  test "returns the query with aggregate max/select" do
    opts = %{
      "$aggregate" => %{"$max" => "nurses"},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity",
      "$select" => ["beds", "nurses", "capacity"]
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(map(f0, [:beds, :nurses, :capacity]), %{
            "$aggregate" => %{"$max": %{^"nurses" => max(f0.nurses)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate max/min" do
    opts = %{
      "$aggregate" => %{"$max" => "nurses", "$min" => "capacity"},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(merge(f0, %{"$aggregate" => %{"$max": %{^"nurses" => max(f0.nurses)}}}), %{
            "$aggregate" => %{"$min": %{^"capacity" => min(f0.capacity)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate count/count_distinct" do
    opts = %{
      "$aggregate" => %{"$count" => "nurses", "$count_distinct" => "capacity"},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(merge(f0, %{"$aggregate" => %{"$count": %{^"nurses" => count(f0.nurses)}}}), %{
            "$aggregate" => %{"$count_distinct": %{^"capacity" => count(f0.capacity, :distinct)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate sum/avg" do
    opts = %{
      "$aggregate" => %{"$sum" => "nurses", "$avg" => "capacity"},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(merge(f0, %{"$aggregate" => %{"$avg": %{^"capacity" => avg(f0.capacity)}}}), %{
            "$aggregate" => %{"$sum": %{^"nurses" => sum(f0.nurses)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate sum/avg as a list" do
    opts = %{
      "$aggregate" => %{"$sum" => ["nurses", "beds"], "$avg" => ["capacity", "nurses"]},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(
            merge(
              merge(merge(f0, %{"$aggregate" => %{"$avg": %{^"capacity" => avg(f0.capacity)}}}), %{
                "$aggregate" => %{"$avg": %{^"nurses" => avg(f0.nurses)}}
              }),
              %{"$aggregate" => %{"$sum": %{^"nurses" => sum(f0.nurses)}}}
            ),
            %{"$aggregate" => %{"$sum": %{^"beds" => sum(f0.beds)}}}
          )
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate count/count_distinct as a list" do
    opts = %{
      "$aggregate" => %{"$count" => ["nurses", "rating"], "$count_distinct" => ["capacity", "beds"]},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(
            merge(
              merge(merge(f0, %{"$aggregate" => %{"$count": %{^"nurses" => count(f0.nurses)}}}), %{
                "$aggregate" => %{"$count": %{^"rating" => count(f0.rating)}}
              }),
              %{"$aggregate" => %{"$count_distinct": %{^"capacity" => count(f0.capacity, :distinct)}}}
            ),
            %{"$aggregate" => %{"$count_distinct": %{^"beds" => count(f0.beds, :distinct)}}}
          )
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate max/min as a list" do
    opts = %{
      "$aggregate" => %{"$max" => ["nurses", "beds"], "$min" => ["capacity", "level"]},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(
            merge(
              merge(merge(f0, %{"$aggregate" => %{"$max": %{^"nurses" => max(f0.nurses)}}}), %{
                "$aggregate" => %{"$max": %{^"beds" => max(f0.beds)}}
              }),
              %{"$aggregate" => %{"$min": %{^"capacity" => min(f0.capacity)}}}
            ),
            %{"$aggregate" => %{"$min": %{^"level" => min(f0.level)}}}
          )
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate count as a list" do
    opts = %{
      "$aggregate" => %{"$count" => ["beds", "rating"]},
      "$where" => %{"beds" => 3}
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.beds == ^3 and ^true,
        select:
          merge(merge(f0, %{"$aggregate" => %{"$count": %{^"beds" => count(f0.beds)}}}), %{
            "$aggregate" => %{"$count": %{^"rating" => count(f0.rating)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate distinct count as a list" do
    opts = %{
      "$aggregate" => %{"$count_distinct" => ["nurses", "level"]},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$desc"}
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        order_by: [desc: f0.beds],
        select:
          merge(
            merge(f0, %{"$aggregate" => %{"$count_distinct": %{^"nurses" => count(f0.nurses, :distinct)}}}),
            %{"$aggregate" => %{"$count_distinct": %{^"level" => count(f0.level, :distinct)}}}
          )
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate min as a list" do
    opts = %{
      "$aggregate" => %{"$min" => ["nurses", "capacity"]},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$desc"},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        order_by: [desc: f0.beds],
        select:
          merge(merge(f0, %{"$aggregate" => %{"$min": %{^"nurses" => min(f0.nurses)}}}), %{
            "$aggregate" => %{"$min": %{^"capacity" => min(f0.capacity)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate max as a list" do
    opts = %{
      "$aggregate" => %{"$max" => ["nurses", "level"]},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(merge(f0, %{"$aggregate" => %{"$max": %{^"nurses" => max(f0.nurses)}}}), %{
            "$aggregate" => %{"$max": %{^"level" => max(f0.level)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate sum as a list" do
    opts = %{
      "$aggregate" => %{"$sum" => ["nurses", "level"]},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$asc"},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        order_by: [asc: f0.beds],
        select:
          merge(merge(f0, %{"$aggregate" => %{"$sum": %{^"nurses" => sum(f0.nurses)}}}), %{
            "$aggregate" => %{"$sum": %{^"level" => sum(f0.level)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate average as a list" do
    opts = %{
      "$aggregate" => %{"$avg" => ["level", "capacity"]},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$asc"},
      "$group" => "capacity"
    }

    expected =
      from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        order_by: [asc: f0.beds],
        select:
          merge(merge(f0, %{"$aggregate" => %{"$avg": %{^"level" => avg(f0.level)}}}), %{
            "$aggregate" => %{"$avg": %{^"capacity" => avg(f0.capacity)}}
          })
      )

    result = Query.build!(FatEcto.FatRoom, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query with aggregate distinct count and a blacklist param" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["description"]}, {:fat_beds, ["is_active"]}]
    )

    opts = %{
      "$aggregate" => %{"$count_distinct" => "description"},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$desc"}
    }

    assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatRoom, opts) end
  end

  test "returns the query with aggregate sum as a list and a blacklist param" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["description"]}, {:fat_beds, ["is_active"]}]
    )

    opts = %{
      "$aggregate" => %{"$sum" => ["nurses", "level"]},
      "$where" => %{"capacity" => 5},
      "$order" => %{"description" => "$asc"},
      "$group" => "capacity"
    }

    assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatRoom, opts) end
  end

  test "returns the query with aggregate avg and a blacklist param" do
    Application.put_env(:fat_ecto, :fat_ecto,
      blacklist_params: [{:fat_rooms, ["some"]}, {:fat_beds, ["is_active"]}]
    )

    opts = %{
      "$aggregate" => %{"$avg" => "level"},
      "$where" => %{"capacity" => 5},
      "$order" => %{"beds" => "$asc"},
      "$group" => "description"
    }

    assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatRoom, opts) end
  end
end
