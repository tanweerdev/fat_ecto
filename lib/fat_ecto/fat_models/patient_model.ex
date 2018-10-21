defmodule FatEcto.FatPatient do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :name,
    :location,
    :phone,
    :address,
    :prescription,
    :symtoms,
    :date_of_birth,
    :appointments_count
  ]

  schema "fat_patients" do
    field(:name, :string, virtual: true)
    field(:location, :string, virtual: true)
    field(:phone, :string, virtual: true)
    field(:address, :string, virtual: true)
    field(:prescription, :string, virtual: true)
    field(:symtoms, :string, virtual: true)
    field(:date_of_birth, :string, virtual: true)
    field(:appointments_count, :integer, virtual: true)
    many_to_many(:doctors, FatEcto.FatDoctor, join_through: FatEcto.FatDoctorPatient)
  end

  def changeset(data) when is_map(data) do
    %__MODULE__{}
    |> cast(data, @fields)
    |> apply_changes()
  end
end
