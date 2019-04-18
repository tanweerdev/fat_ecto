defmodule FatEcto.Repo.Migrations.CreateDoctorPatient do
  use Ecto.Migration

  def change do
    create table(:fat_doctors_patients) do
    add(:fat_doctor_id, references(:fat_doctors))
    add(:fat_patient_id, references(:fat_patients))
    end  
  end
end
