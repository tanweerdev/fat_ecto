defmodule FatEcto.FatDoctor do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:name, :designation, :phone, :address, :email, :experience_years, :rating, :start_date, :end_date]

  schema "fat_doctors" do
    field(:name, :string)
    field(:designation, :string)
    field(:phone, :string)
    field(:address, :string)
    field(:email, :string)
    field(:experience_years, :integer)
    field(:rating, :integer)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    many_to_many(:fat_hospitals, FatEcto.FatHospital, join_through: FatEcto.FatHospitalDoctor)
    many_to_many(:fat_patients, FatEcto.FatPatient, join_through: FatEcto.FatDoctorPatient)
  end

  def changeset(data) when is_map(data) do
    %__MODULE__{}
    |> cast(data, @fields)
    |> validate_required([:name, :designation])
  end

  def struct(data) when is_map(data) do
    %__MODULE__{}
    |> cast(data, @fields)
    |> apply_changes()
  end
end