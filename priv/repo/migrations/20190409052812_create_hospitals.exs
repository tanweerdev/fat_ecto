defmodule FatEcto.Repo.Migrations.CreateHospitals do
  use Ecto.Migration

  def change do
    create table(:fat_hospitals) do
      add(:name, :string)
      add(:location, :string)
      add(:phone, :string)
      add(:address, :string)
      add(:total_staff, :integer)
      add(:rating, :integer)
    end
  end
end
