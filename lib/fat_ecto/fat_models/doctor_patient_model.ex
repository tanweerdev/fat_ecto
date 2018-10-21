defmodule FatEcto.FatDoctorPatient do
  @moduledoc false
  use Ecto.Schema

  schema "fat_doctors_patients" do
    belongs_to(:doctor, FatEcto.FatDoctor)
    belongs_to(:patient, FatEcto.FatPatient)
  end
end
