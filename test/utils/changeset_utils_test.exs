defmodule Utils.ChangesetTest do
  use FatEcto.ConnCase
  alias FatUtils.Changeset, as: Change

  test "require_xor changeset" do
    changeset = FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{name: "12345", designation: "testing"})
    {:ok, struct} = Repo.insert(changeset)

    changeset = Change.require_xor(changeset, struct, [:name, :designation])
    assert changeset.errors == [designation: {"name XOR designation", []}, name: {"name XOR designation", []}]

    changeset = FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{name: "12345", designation: "testing"})

    changeset = Change.require_xor(changeset, struct, [:name])
    assert changeset.errors == [name: {"name", []}]

    changeset = FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{name: "12345", designation: "testing"})
    changeset = Change.require_xor(changeset, struct, [:phone])

    assert changeset.errors == [
             phone: {"phone fields can not be empty at the same time", [validation: :required]}
           ]
  end

  test "require_or changeset" do
    changeset = FatEcto.FatBed.changeset(%FatEcto.FatBed{}, %{name: "12345", designation: "testing"})
    changeset = Change.require_or(changeset, %FatEcto.FatBed{}, [:name, :designation])
    assert changeset.errors == []

    changeset = FatEcto.FatBed.changeset(%FatEcto.FatBed{}, %{name: "12345"})
    changeset = Change.require_or(changeset, %FatEcto.FatBed{}, [:name, :designation])
    assert changeset.errors == []

    changeset = FatEcto.FatBed.changeset(%FatEcto.FatBed{}, %{})
    changeset = Change.require_or(changeset, %FatEcto.FatBed{}, [:name, :designation])

    assert changeset.errors == [
             designation: {"name OR designation required", []},
             name: {"name OR designation required", []}
           ]
  end

  test "require if change present" do
    changeset = FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{name: "12345", designation: "testing"})
    changeset = Change.require_if_change_present(changeset, if_change_key: :name, require_key: :phone)
    assert changeset.errors == [phone: {"can't be blank", [validation: :required]}]
  end

  test "validate before" do
    {:ok, start_date, _} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    {:ok, end_date, _} = DateTime.from_iso8601("2016-01-02T01:00:00Z")

    changeset =
      FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{
        start_date: start_date,
        end_date: end_date,
        name: "12345",
        designation: "testing"
      })

    changeset = Change.validate_before(changeset, :start_date, :end_date)
    assert changeset.errors == [start_date: {"must be before end_date", []}]
    changeset = Change.validate_before(changeset, :start_date, :end_date, compare_type: :time)
    assert changeset.errors == [start_date: {"must be before end_date", []}]

    {:ok, start_date, _} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    {:ok, end_date, _} = DateTime.from_iso8601("2017-01-01T00:00:00Z")

    changeset =
      FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{
        start_date: start_date,
        end_date: end_date,
        name: "12345",
        designation: "testing"
      })

    changeset = Change.validate_before(changeset, :start_date, :end_date)
    assert changeset.errors == [start_date: {"must be before end_date", []}]
  end

  test "validate before equal" do
    {:ok, start_date, _} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    {:ok, end_date, _} = DateTime.from_iso8601("2016-01-02T01:00:00Z")

    changeset =
      FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{
        start_date: start_date,
        end_date: end_date,
        name: "12345",
        designation: "testing"
      })

    changeset = Change.validate_before_equal(changeset, :start_date, :end_date)
    assert changeset.errors == [start_date: {"must be before or equal to end_date", []}]
    changeset = Change.validate_before_equal(changeset, :start_date, :end_date, compare_type: :time)
    assert changeset.errors == [start_date: {"must be before or equal to end_date", []}]

    {:ok, start_date, _} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    {:ok, end_date, _} = DateTime.from_iso8601("2017-01-01T00:00:00Z")

    changeset =
      FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{
        start_date: start_date,
        end_date: end_date,
        name: "12345",
        designation: "testing"
      })

    changeset = Change.validate_before_equal(changeset, :start_date, :end_date)
    assert changeset.valid?
  end

  test "error message title" do
    error =
      Change.error_msg_title(
        [error_message_title: :name_field, error_message: "must always be present in changest"],
        :name,
        "must be present"
      )

    assert error == {:name_field, "must always be present in changest"}
    error = Change.error_msg_title([], :name, "must be present")
    assert error == {:name, "must be present"}
  end

  test "add error" do
    orgnl_changeset =
      FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{name: "12345", designation: "testing"})

    changeset = Change.add_error(orgnl_changeset, :phone, "must be present")
    assert changeset.errors == [phone: {"must be present", []}]
    changeset = Change.add_error(orgnl_changeset, :name)
    assert changeset.errors == [name: {"is invalid", []}]
  end
end
