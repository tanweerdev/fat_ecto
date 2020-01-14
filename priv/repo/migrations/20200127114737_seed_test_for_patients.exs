defmodule FatEcto.Repo.Migrations.SeedTestForPatients do
  use Ecto.Migration
  import Ecto.Query

  use FatUtils.SeedHelper, otp_app: :fat_ecto, seed_base_path: "priv/csvs"

  def change do
    import_from_csv("test_patients", &map_to_table(&1, "fat_patients"))
  end
end
