defmodule Fat.ContextTest do
  use ExUnit.Case
  alias FatTest.ContextMacro
  alias FatEcto.{Repo, ContextModel, Sibling}
  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Repo.start_link()
    Repo.insert(%ContextModel{name: "John", purpose: "Testing", description: "descriptive", is_active: true})

    :ok
  end

  test "return first record from table with association" do
    Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    context =
      from(c in ContextModel,
        where: c.name == "John",
        limit: 1
      )
      |> Repo.one()

    Repo.insert(%Sibling{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      context_id: context.id,
      phone: "123456"
    })

    record = ContextMacro.first(FatEcto.ContextModel, [:siblings])
    assert record.is_active == true
    assert record.name == "John"
    sibling = List.first(record.siblings)
    assert sibling.context_id == context.id
  end

  test "return last record from table with association" do
    Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    context =
      from(c in ContextModel,
        where: c.name == "Doe",
        limit: 1
      )
      |> Repo.one()

    Repo.insert(%Sibling{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      context_id: context.id,
      phone: "123456"
    })

    record = ContextMacro.last(FatEcto.ContextModel, [:siblings])
    assert record.is_active == false
    assert record.name == "Doe"
    sibling = List.first(record.siblings)
    assert sibling.context_id == context.id
  end

  test "count records in the table" do
    Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})
    Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    assert ContextMacro.count(ContextModel) == 3
  end

  test "count records in the table with specific condition" do
    Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})
    Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    assert ContextMacro.count(ContextModel, name: "Doe") == 2
  end

  test "preload schema and associations" do
    {:ok, context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    {:ok, context_1} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%Sibling{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      context_id: context.id,
      phone: "123456"
    })

    Repo.insert(%Sibling{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      context_id: context_1.id,
      phone: "123456"
    })

    list = ContextMacro.list(ContextModel, [:siblings])
    assert Enum.count(list) == 3
  end

  test "get record " do
    {:ok, context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    record = ContextMacro.get!(ContextModel, context.id)
    assert record.id == context.id
  end

  test "get record in tuple and preload association " do
    {:ok, context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%Sibling{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      context_id: context.id,
      phone: "123456"
    })

    {:ok, record} = ContextMacro.get(ContextModel, context.id)
    assert record.id == context.id

    result = ContextMacro.get(ContextModel, -1)
    assert result == {:error, :not_found}

    {:ok, record} = ContextMacro.get(ContextModel, context.id, [:siblings])
    sibling = record.siblings |> List.first()
    assert sibling.context_id == context.id
  end

  test "get record with string id" do
    record = ContextMacro.get_catch(ContextModel, "fsg")
    assert record == {:error, :invalid_id}
  end

  test "get by record with preload association" do
    {:ok, context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%Sibling{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      context_id: context.id,
      phone: "123456"
    })

    record = ContextMacro.get_by(ContextModel, name: "Doe")
    assert record.name == "Doe"

    record = ContextMacro.get_by(ContextModel, [name: "Doe"], [:siblings])

    sibling = record.siblings |> List.first()
    assert sibling.context_id == context.id
  end

  test "create record" do
    {:ok, record} = ContextMacro.create(ContextModel, %{name: "Doe", purpose: "Testing"})
    assert record.name == "Doe"
  end

  test "update record" do
    {:ok, context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    {:ok, record} = ContextMacro.update(ContextModel, context, %{name: "John"})
    assert record.name == "John"
  end

  test "delete record" do
    {:ok, context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    ContextMacro.delete(context)
    assert Repo.get(ContextModel, context.id) == nil
  end

  test "delete all records from schema" do
    {:ok, _context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    ContextMacro.delete_all(ContextModel)
    assert Repo.all(ContextModel) == []
  end

  test "make changeset from schema" do
    {:ok, context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    changeset = ContextMacro.changeset(ContextModel, context, %{name: "Doe", purpose: "Testing"})
    assert changeset.valid?
  end

  test "Get all records with associations and which meets specific condition" do
    {:ok, context} =
      Repo.insert(%ContextModel{name: "Doe", purpose: "Testing", description: "descriptive", is_active: false})

    Repo.insert(%Sibling{
      name: "John",
      purpose: "Testing",
      description: "descriptive",
      is_active: false,
      context_id: context.id,
      phone: "123456"
    })

    record = ContextMacro.get_all_by(ContextModel, [name: "Doe"], [:siblings])
  end
end
