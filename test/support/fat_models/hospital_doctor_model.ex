defmodule FatEcto.FatHospitalDoctor do
  @moduledoc false
  use Ecto.Schema

  schema "fat_hospitals_doctors" do
    belongs_to(:fat_doctor, FatEcto.FatDoctor)
    belongs_to(:fat_hospital, FatEcto.FatHospital)
  end
end
