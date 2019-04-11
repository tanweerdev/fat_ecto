defmodule FatEcto.Repo.Migrations.CreateSiblings do
  use Ecto.Migration

  def change do
    create table(:fat_beds) do
      add(:name, :string)
      add(:purpose, :string)
      add(:description, :string)
      add(:is_active, :boolean)
      add(:fat_room_id, references(:fat_rooms))
    end
  end
end
