defmodule FatEcto.Repo.Migrations.PrimaryKeyFalseForHospitalDoctors do
  use Ecto.Migration

  def change do
    drop(constraint(:fat_hopitals_doctors, "fat_hopitals_doctors_fat_doctor_id_fkey"))
    drop(constraint(:fat_hopitals_doctors, "fat_hopitals_doctors_fat_hospital_id_fkey"))

    alter table(:fat_hopitals_doctors, primary_key: false) do
      remove(:id)
      modify(:fat_doctor_id, references(:fat_doctors), null: false, primary_key: true)
      modify(:fat_hospital_id, references(:fat_hospitals), null: false, primary_key: true)
    end
  end
end
