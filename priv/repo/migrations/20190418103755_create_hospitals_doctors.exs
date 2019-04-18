defmodule FatEcto.Repo.Migrations.CreateHospitalsDoctors do
  use Ecto.Migration

  def change do
    create table(:fat_hopitals_doctors) do
      add(:fat_doctor_id, references(:fat_doctors))
      add(:fat_hospital_id, references(:fat_hospitals))
    end
  end
end
