defmodule FatEcto.FatDoctorPatient do
  @moduledoc false
  use Ecto.Schema

  schema "fat_doctors_patients" do
    belongs_to(:fat_doctor, FatEcto.FatDoctor)
    belongs_to(:fat_patient, FatEcto.FatPatient)
  end
end
