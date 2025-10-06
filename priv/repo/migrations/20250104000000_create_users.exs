defmodule FatEcto.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:fat_users) do
      add(:name, :string)
      add(:email, :string)
      add(:age, :integer)
      add(:city, :string)
      add(:status, :string)
      add(:rating, :float)
      add(:created_at, :utc_datetime)
      add(:phone, :string)
      add(:is_active, :boolean, default: false)
    end

    create(index(:fat_users, [:email]))
    create(index(:fat_users, [:created_at]))
  end
end
