defmodule FatEcto.FatDoctorPatient do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset


  schema "fat_doctors_patients" do
    belongs_to(:fat_doctor, FatEcto.FatDoctor)
    belongs_to(:fat_patient, FatEcto.FatPatient)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :fat_doctor_id,
      :fat_patient_id
    ])
  end
end
