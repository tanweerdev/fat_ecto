defmodule Fat.ContextTest do
  use FatEcto.ConnCase
  import FatEcto.Factory
  alias Fat.TestContext
  alias FatEcto.{FatRoom, Repo}

  setup do
    Repo.start_link()
    :ok
  end

  test "first/2 returns the first record with associations" do
    # Insert rooms and a bed associated with the first room
    room1 = insert(:room, name: "John", is_active: true)
    insert(:room, name: "Doe", is_active: false)
    insert(:bed, fat_room_id: room1.id)

    # Fetch the first room with preloaded beds
    record = TestContext.first(FatRoom, [:fat_beds])

    # Assertions
    assert record.is_active == true, "Expected the first room to be active"
    assert record.name == "John", "Expected the first room to have the name 'John'"
    sibling = List.first(record.fat_beds)
    assert sibling.fat_room_id == room1.id, "Expected the bed to be associated with the room"
  end

  test "last/2 returns the last record with associations" do
    # Insert rooms and a bed associated with the last room
    insert(:room, name: "John", is_active: true)
    room2 = insert(:room, name: "Doe", is_active: false)
    insert(:bed, fat_room_id: room2.id)

    # Fetch the last room with preloaded beds
    record = TestContext.last(FatRoom, [:fat_beds])

    # Assertions
    assert record.is_active == false, "Expected the last room to be inactive"
    assert record.name == "Doe", "Expected the last room to have the name 'Doe'"
    sibling = List.first(record.fat_beds)
    assert sibling.fat_room_id == room2.id, "Expected the bed to be associated with the room"
  end

  test "count/1 returns the total number of records in the table" do
    # Insert additional rooms
    insert(:room, name: "John")
    insert(:room, name: "Doe")
    insert(:room, name: "Jane")

    # Assert the total count
    assert TestContext.count(FatRoom) == 3, "Expected 3 rooms in the table"
  end

  test "count/2 returns the number of records matching a condition" do
    # Insert additional rooms with the same name
    insert(:room, name: "Doe")
    insert(:room, name: "Doe")

    # Assert the count of rooms with the name "Doe"
    assert TestContext.count(FatRoom, name: "Doe") == 2, "Expected 2 rooms with the name 'Doe'"
  end

  test "list/2 returns all records with preloaded associations" do
    # Insert additional rooms and beds
    room1 = insert(:room, name: "Doe")
    room2 = insert(:room, name: "Jane")
    insert(:bed, fat_room_id: room1.id)
    insert(:bed, fat_room_id: room2.id)

    # Fetch all rooms with preloaded beds
    list = TestContext.list(FatRoom, [:fat_beds])

    # Assertions
    assert Enum.count(list) == 2, "Expected 2 rooms in the list"
    assert Enum.any?(list, &(&1.name == "Doe")), "Expected a room with the name 'Doe'"
    assert Enum.any?(list, &(&1.name == "Jane")), "Expected a room with the name 'Jane'"
  end

  test "get!/2 returns a record by ID or raises if not found" do
    # Insert a room
    room = insert(:room)

    # Fetch the room by ID
    record = TestContext.get!(FatRoom, room.id)

    # Assertions
    assert record.id == room.id, "Expected the fetched room to match the inserted room"

    # Test raising an error for a non-existent ID
    assert_raise Ecto.NoResultsError, fn ->
      TestContext.get!(FatRoom, -1)
    end
  end

  test "get/3 returns a record by ID with preloaded associations or an error tuple if not found" do
    # Insert a room and a bed
    room = insert(:room)
    insert(:bed, fat_room_id: room.id)

    # Fetch the room by ID with preloaded beds
    {:ok, record} = TestContext.get(FatRoom, room.id, [:fat_beds])

    # Assertions
    assert record.id == room.id, "Expected the fetched room to match the inserted room"
    sibling = List.first(record.fat_beds)
    assert sibling.fat_room_id == room.id, "Expected the bed to be associated with the room"

    # Test error tuple for a non-existent ID
    assert TestContext.get(FatRoom, -1) == {:error, :not_found}
  end

  test "get_by/3 returns a record by conditions with preloaded associations or an error tuple if not found" do
    # Insert a room and a bed
    room = insert(:room, name: "Doe")
    insert(:bed, fat_room_id: room.id)

    # Fetch the room by name with preloaded beds
    {:ok, record} = TestContext.get_by(FatRoom, [name: "Doe"], [:fat_beds])

    # Assertions
    assert record.name == "Doe", "Expected the fetched room to have the name 'Doe'"
    sibling = List.first(record.fat_beds)
    assert sibling.fat_room_id == room.id, "Expected the bed to be associated with the room"

    # Test error tuple for a non-existent condition
    assert TestContext.get_by(FatRoom, name: "Non-existent") == {:error, :not_found}
  end

  test "create/2 creates a new record" do
    # Create a new room
    {:ok, record} = TestContext.create(FatRoom, %{name: "Doe", purpose: "Testing"})

    # Assertions
    assert record.name == "Doe", "Expected the created room to have the name 'Doe'"
  end

  test "update/4 updates an existing record" do
    # Insert a room
    room = insert(:room)

    # Update the room's name
    {:ok, record} = TestContext.update(room, FatRoom, %{name: "John"})

    # Assertions
    assert record.name == "John", "Expected the updated room to have the name 'John'"
  end

  test "delete/1 deletes a record" do
    # Insert a room
    room = insert(:room)

    # Delete the room
    TestContext.delete(room)

    # Assertions
    assert Repo.get(FatRoom, room.id) == nil, "Expected the room to be deleted"
  end

  test "delete_all/1 deletes all records from the schema" do
    # Insert multiple rooms
    insert(:room)
    insert(:room)

    # Delete all rooms
    TestContext.delete_all(FatRoom)

    # Assertions
    assert Repo.all(FatRoom) == [], "Expected all rooms to be deleted"
  end

  test "changeset/3 creates a changeset for a record" do
    # Insert a room
    room = insert(:room)

    # Create a changeset
    changeset = TestContext.changeset(FatRoom, room, %{name: "Doe", purpose: "Testing"})

    # Assertions
    assert changeset.valid?, "Expected the changeset to be valid"
  end

  test "get_all_by/3 returns all records matching conditions with preloaded associations" do
    # Insert multiple rooms and beds
    room1 = insert(:room, name: "Doe")
    room2 = insert(:room, name: "Doe")
    insert(:bed, fat_room_id: room1.id)
    insert(:bed, fat_room_id: room2.id)

    # Fetch all rooms with the name "Doe" and preloaded beds
    records = TestContext.get_all_by(FatRoom, [name: "Doe"], [:fat_beds])

    # Assertions
    assert Enum.count(records) == 2, "Expected 2 rooms with the name 'Doe'"
    assert Enum.all?(records, &(&1.name == "Doe")), "Expected all fetched rooms to have the name 'Doe'"
  end
end
