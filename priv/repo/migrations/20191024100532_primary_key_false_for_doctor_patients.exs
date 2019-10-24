defmodule FatEcto.Repo.Migrations.PrimaryKeyFalseForDoctorPatients do
  use Ecto.Migration

  def change do
    drop(constraint(:fat_doctors_patients, "fat_doctors_patients_fat_doctor_id_fkey"))
    drop(constraint(:fat_doctors_patients, "fat_doctors_patients_fat_patient_id_fkey"))

    alter table(:fat_doctors_patients, primary_key: false) do
      remove(:id)

      modify(:fat_doctor_id, references(:fat_doctors), null: false, primary_key: true)

      modify(:fat_patient_id, references(:fat_patients), null: false, primary_key: true)
    end
  end
end
