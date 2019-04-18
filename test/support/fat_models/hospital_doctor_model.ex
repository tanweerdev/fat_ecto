defmodule FatEcto.FatHospitalDoctor do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "fat_hospitals_doctors" do
    belongs_to(:fat_doctor, FatEcto.FatDoctor)
    belongs_to(:fat_hospital, FatEcto.FatHospital)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :fat_doctor_id,
      :fat_hospital_id
    ])
  end
end
