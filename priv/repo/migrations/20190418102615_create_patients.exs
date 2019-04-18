defmodule FatEcto.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:fat_patients) do
      add(:name, :string)
      add(:location, :string)
      add(:phone, :string)
      add(:address, :string)
      add(:prescription, :string)
      add(:symtoms, :integer)
      add(:date_of_birth, :string)
      add(:appointments_count, :integer)
    end
  end
end
