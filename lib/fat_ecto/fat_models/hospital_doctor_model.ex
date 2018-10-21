defmodule FatEcto.FatHospitalDoctor do
  @moduledoc false
  use Ecto.Schema

  schema "fat_hospitals_doctors" do
    belongs_to(:doctor, FatEcto.FatDoctor)
    belongs_to(:hospital, FatEcto.FatHospital)
  end
end
