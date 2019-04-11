defmodule FatEcto.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:fat_rooms) do
      add(:name, :string)
      add(:purpose, :string)
      add(:description, :string)
      add(:floor, :integer)
      add(:is_active, :boolean)
      add(:fat_hospital_id, references(:fat_hospitals))
    end
  end
end
