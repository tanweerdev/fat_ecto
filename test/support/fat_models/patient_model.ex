defmodule FatEcto.FatPatient do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "fat_patients" do
    field(:name, :string)
    field(:location, :string)
    field(:phone, :string)
    field(:address, :string)
    field(:prescription, :string)
    field(:symptoms, :string)
    field(:date_of_birth, :string)
    field(:appointments_count, :integer)
    many_to_many(:fat_doctors, FatEcto.FatDoctor, join_through: FatEcto.FatDoctorPatient)
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [
      :name,
      :location,
      :phone,
      :address,
      :prescription,
      :symptoms,
      :date_of_birth,
      :appointments_count
    ])
  end
end
