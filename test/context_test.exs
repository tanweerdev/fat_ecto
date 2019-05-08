defmodule Fat.ContextTest do
  use FatEcto.ConnCase
  alias Fat.ContextMacro
  alias FatEcto.{Repo, FatRoom, FatBed}

  setup do
    Repo.start_link()
    Repo.insert(%FatRoom{name: "John", purpose: "Testing", description: "descriptive", is_active: true})

    :ok
  end

  test "return first record from table with association" do
    Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    room =
      from(c in FatRoom,
        where: c.name == "John",
        limit: 1
      )
      |> Repo.one()

    Repo.insert(%FatBed{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      fat_room_id: room.id
    })

    record = ContextMacro.first(FatEcto.FatRoom, [:fat_beds])
    assert record.is_active == true
    assert record.name == "John"
    sibling = List.first(record.fat_beds)
    assert sibling.fat_room_id == room.id
  end

  test "return last record from table with association" do
    Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    room =
      from(c in FatRoom,
        where: c.name == "Doe",
        limit: 1
      )
      |> Repo.one()

    Repo.insert(%FatBed{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      fat_room_id: room.id
    })

    record = ContextMacro.last(FatEcto.FatRoom, [:fat_beds])
    assert record.is_active == false
    assert record.name == "Doe"
    sibling = List.first(record.fat_beds)
    assert sibling.fat_room_id == room.id
  end

  test "count records in the table" do
    Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})
    Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    assert ContextMacro.count(FatRoom) == 3
  end

  test "count records in the table with specific condition" do
    Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})
    Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    assert ContextMacro.count(FatRoom, name: "Doe") == 2
  end

  test "preload schema and associations" do
    {:ok, room} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    {:ok, room_1} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%FatBed{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      fat_room_id: room.id
    })

    Repo.insert(%FatBed{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      fat_room_id: room_1.id
    })

    list = ContextMacro.list(FatRoom, [:fat_beds])
    assert Enum.count(list) == 3
  end

  test "get record " do
    {:ok, room} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    record = ContextMacro.get!(FatRoom, room.id)
    assert record.id == room.id
  end

  test "get record in tuple and preload association " do
    {:ok, room} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%FatBed{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      fat_room_id: room.id
    })

    {:ok, record} = ContextMacro.get(FatRoom, room.id)
    assert record.id == room.id

    result = ContextMacro.get(FatRoom, -1)
    assert result == {:error, :not_found}

    {:ok, record} = ContextMacro.get(FatRoom, room.id, [:fat_beds])
    sibling = record.fat_beds |> List.first()
    assert sibling.fat_room_id == room.id
  end

  test "get record with string id" do
    record = ContextMacro.get_catch(FatRoom, "fsg")
    assert record == {:error, :invalid_id}
  end

  test "get by record with preload association" do
    {:ok, room} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%FatBed{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      fat_room_id: room.id
    })

    {:ok, record} = ContextMacro.get_by(FatRoom, name: "Doe")
    assert record.name == "Doe"

    {:ok, record} = ContextMacro.get_by(FatRoom, [name: "Doe"], [:fat_beds])

    sibling = record.fat_beds |> List.first()
    assert sibling.fat_room_id == room.id
  end

  test "create record" do
    {:ok, record} = ContextMacro.create(FatRoom, %{name: "Doe", purpose: "Testing"})
    assert record.name == "Doe"
  end

  test "update record" do
    {:ok, context} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    {:ok, record} = ContextMacro.update(context, FatRoom, %{name: "John"})
    assert record.name == "John"
  end

  test "delete record" do
    {:ok, room} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    ContextMacro.delete(room)
    assert Repo.get(FatRoom, room.id) == nil
  end

  test "delete all records from schema" do
    {:ok, _context} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    ContextMacro.delete_all(FatRoom)
    assert Repo.all(FatRoom) == []
  end

  test "make changeset from schema" do
    {:ok, room} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    changeset = ContextMacro.changeset(FatRoom, room, %{name: "Doe", purpose: "Testing"})
    assert changeset.valid?
  end

  test "Get all records with associations and which meets specific condition" do
    {:ok, room} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%FatBed{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      fat_room_id: room.id
    })

    record = ContextMacro.get_all_by(FatRoom, [name: "Doe"], [:fat_beds])
    assert record |> Enum.count() == 2
  end

  @tag :failing
  test "insert record and use fat ecto to query the result" do
    {:ok, room} =
      Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%FatRoom{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    {:ok, bed} =
      Repo.insert(%FatBed{
        name: "John",
        purpose: "Testing",
        description: "descriptive",
        is_active: false,
        fat_room_id: room.id
      })

    opts = %{
      "$right_join" => %{
        "fat_beds" => %{
          "$on_field" => "id",
          "$on_join_table_field" => "fat_room_id",
          "$select" => ["name", "purpose", "description"],
          "$where" => %{"id" => bed.id}
        }
      },
      "$where" => %{"id" => room.id}
    }

    result = Query.build(FatEcto.FatRoom, opts)
    Repo.all(result)
  end
end
