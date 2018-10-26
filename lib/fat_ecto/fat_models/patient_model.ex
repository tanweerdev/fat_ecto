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
    field(:name, :string)
    field(:location, :string)
    field(:phone, :string)
    field(:address, :string)
    field(:prescription, :string)
    field(:symtoms, :string)
    field(:date_of_birth, :string)
    field(:appointments_count, :integer)
    many_to_many(:fat_doctors, FatEcto.FatDoctor, join_through: FatEcto.FatDoctorPatient)
  end

  def changeset(data) when is_map(data) do
    %__MODULE__{}
    |> cast(data, @fields)
    |> apply_changes()
  end
end
