defmodule FatEcto.FatDoctorPatient do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false

  schema "fat_doctors_patients" do
    belongs_to(:fat_doctor, FatEcto.FatDoctor, primary_key: true)
    belongs_to(:fat_patient, FatEcto.FatPatient, primary_key: true)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :fat_doctor_id,
      :fat_patient_id
    ])
    |> validate_required([:fat_doctor_id,
    :fat_patient_id])
    |> foreign_key_constraint(:fat_doctor_id)
    |> foreign_key_constraint(:fat_patient_id)
  end
end
