defmodule Utils.ChangesetTest do
  use FatEcto.ConnCase
  import FatEcto.Factory
  alias FatUtils.Changeset, as: Change

  describe "validate_xor_fields/4" do
    test "returns errors when both XOR fields are present" do
      struct = insert(:doctor)
      changeset = FatEcto.FatDoctor.changeset(struct, %{name: "12345", designation: "designation"})

      changeset = Change.validate_xor_fields(changeset, struct, [:name, :designation])

      assert changeset.errors == [
               designation: {"name XOR designation", []},
               name: {"name XOR designation", []}
             ]
    end

    test "returns errors when all XOR fields are empty" do
      struct = %FatEcto.FatDoctor{name: "12345", designation: "designation"}
      changeset = FatEcto.FatDoctor.changeset(struct, %{})

      changeset = Change.validate_xor_fields(changeset, struct, [:phone, :address])

      assert changeset.errors == [
               {:address,
                {"phone XOR address fields cannot be empty at the same time", [validation: :required]}},
               {:phone,
                {"phone XOR address fields cannot be empty at the same time", [validation: :required]}}
             ]
    end

    test "does not return errors when only one XOR field is present" do
      changeset = :doctor |> build(name: "12345") |> FatEcto.FatDoctor.changeset(%{})
      struct = Repo.insert!(changeset)

      changeset = Change.validate_xor_fields(changeset, struct, [:name, :designation])
      assert changeset.errors == []
    end
  end

  describe "validate_at_least_one_field/4" do
    test "returns errors when none of the OR fields are present" do
      changeset = :bed |> build() |> FatEcto.FatBed.changeset(%{})
      changeset = Change.validate_at_least_one_field(changeset, %FatEcto.FatBed{}, [:name, :description])

      assert changeset.errors == [
               description: {"name OR description required", []},
               name: {"name OR description required", []}
             ]
    end

    test "does not return errors when at least one OR field is present" do
      changeset = FatEcto.FatBed.changeset(%FatEcto.FatBed{}, %{name: "12345"})
      changeset = Change.validate_at_least_one_field(changeset, %FatEcto.FatBed{}, [:name, :description])
      assert changeset.errors == []
    end
  end

  describe "require_field_if_present/3" do
    test "makes a field required if another field is present" do
      changeset =
        FatEcto.FatDoctor.changeset(%FatEcto.FatDoctor{}, %{name: "12345", designation: "designation"})

      changeset = Change.require_field_if_present(changeset, if_change_key: :name, require_key: :phone)
      assert changeset.errors == [phone: {"can't be blank", [validation: :required]}]
    end

    test "does not require a field if the other field is not present" do
      changeset = :doctor |> build() |> FatEcto.FatDoctor.changeset(%{})
      changeset = Change.require_field_if_present(changeset, if_change_key: :name, require_key: :phone)
      assert changeset.errors == []
    end
  end

  describe "validate_start_before_end/4" do
    test "returns errors when start date is after end date" do
      changeset =
        :doctor
        |> build(start_date: ~U[2017-01-01T00:00:00Z], end_date: ~U[2016-01-02T01:00:00Z])
        |> FatEcto.FatDoctor.changeset(%{})

      changeset = Change.validate_start_before_end(changeset, :start_date, :end_date)
      assert changeset.errors == [start_date: {"must be before end_date", []}]
    end

    test "returns errors when start time is after end time" do
      changeset =
        :doctor
        |> build(start_date: ~U[2017-01-01T10:00:00Z], end_date: ~U[2017-01-01T09:00:00Z])
        |> FatEcto.FatDoctor.changeset(%{})

      changeset = Change.validate_start_before_end(changeset, :start_date, :end_date, compare_type: :time)
      assert changeset.errors == [start_date: {"must be before end_date", []}]
    end

    test "does not return errors when start date is before end date" do
      changeset =
        :doctor
        |> build(start_date: ~U[2016-01-01T00:00:00Z], end_date: ~U[2017-01-02T01:00:00Z])
        |> FatEcto.FatDoctor.changeset(%{})

      changeset = Change.validate_start_before_end(changeset, :start_date, :end_date)
      assert changeset.errors == []
    end
  end

  describe "validate_start_before_or_equal_end/4" do
    test "returns errors when start date is after end date" do
      changeset =
        :doctor
        |> build(start_date: ~U[2017-01-01T00:00:00Z], end_date: ~U[2016-01-02T01:00:00Z])
        |> FatEcto.FatDoctor.changeset(%{})

      changeset = Change.validate_start_before_or_equal_end(changeset, :start_date, :end_date)
      assert changeset.errors == [start_date: {"must be before or equal to end_date", []}]
    end

    test "does not return errors when start date is equal to end date" do
      changeset =
        :doctor
        |> build(start_date: ~U[2017-01-01T00:00:00Z], end_date: ~U[2017-01-01T00:00:00Z])
        |> FatEcto.FatDoctor.changeset(%{})

      changeset = Change.validate_start_before_or_equal_end(changeset, :start_date, :end_date)
      assert changeset.valid?
    end
  end

  describe "add_custom_error/3" do
    test "adds a custom error to the changeset" do
      changeset = :doctor |> build(name: "12345") |> FatEcto.FatDoctor.changeset(%{})
      changeset = Change.add_custom_error(changeset, :phone, "must be present")
      assert changeset.errors == [phone: {"must be present", []}]
    end

    test "adds a default error message when none is provided" do
      changeset = :doctor |> build(name: "12345") |> FatEcto.FatDoctor.changeset(%{})
      changeset = Change.add_custom_error(changeset, :name)
      assert changeset.errors == [name: {"is invalid", []}]
    end
  end

  describe "validate_only_one_field/4" do
    test "returns errors when multiple fields are present" do
      changeset = :bed |> build(name: "12345", description: "testing") |> FatEcto.FatBed.changeset(%{})
      changeset = Change.validate_only_one_field(changeset, %FatEcto.FatBed{}, [:name, :description])

      assert changeset.errors == [
               description: {"only one of name or description is required", []},
               name: {"only one of name or description is required", []}
             ]
    end

    test "does not return errors when only one field is present" do
      changeset = FatEcto.FatBed.changeset(%FatEcto.FatBed{}, %{name: "12345"})
      changeset = Change.validate_only_one_field(changeset, %FatEcto.FatBed{}, [:name, :description])
      assert changeset.errors == []
    end

    test "returns errors when no fields are present" do
      changeset = FatEcto.FatBed.changeset(%FatEcto.FatBed{}, %{})
      changeset = Change.validate_only_one_field(changeset, %FatEcto.FatBed{}, [:name, :description])

      assert changeset.errors == [
               description: {"only one of name or description is required", []},
               name: {"only one of name or description is required", []}
             ]
    end
  end
end
