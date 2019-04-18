defmodule FatEcto.Repo.Migrations.CreateDoctors do
  use Ecto.Migration

  def change do
    create table(:fat_doctors) do
      add(:name, :string)
      add(:designation, :string)
      add(:phone, :string)
      add(:address, :string)
      add(:email, :string)
      add(:experience_years, :integer)
      add(:rating, :integer)
      add(:start_date, :utc_datetime)
      add(:end_date, :utc_datetime)
    end
  end
end
