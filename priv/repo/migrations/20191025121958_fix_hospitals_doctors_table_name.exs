defmodule FatEcto.Repo.Migrations.FixHospitalsDoctorsTableName do
  use Ecto.Migration

  def change do
    rename(table("fat_hopitals_doctors"), to: table("fat_hospitals_doctors"))
  end
end
