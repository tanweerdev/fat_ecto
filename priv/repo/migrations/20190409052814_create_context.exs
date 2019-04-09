defmodule FatEcto.Repo.Migrations.CreateContext do
  use Ecto.Migration

  def change do
    create table(:contexts) do
      add(:name, :string)
      add(:purpose, :string)
      add(:description, :string)
      add(:is_active, :boolean)

    end
  end
end
