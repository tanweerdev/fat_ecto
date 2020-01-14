defmodule FatEcto.Repo.Migrations.ChangePatientsSymptomsDatatype do
  use Ecto.Migration

  def change do
    alter table(:fat_patients) do
      remove(:symtoms)
      add(:symptoms, :string)
    end
  end
end
