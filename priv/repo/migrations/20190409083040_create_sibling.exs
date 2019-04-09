defmodule FatEcto.Repo.Migrations.CreateSibling do
  use Ecto.Migration

  def change do
    create table(:siblings) do
      add(:name, :string)
      add(:purpose, :string)
      add(:phone, :string)
      add(:description, :string)
      add(:is_active, :boolean)
      add(:context_id, references(:contexts))


    end
  end
end
