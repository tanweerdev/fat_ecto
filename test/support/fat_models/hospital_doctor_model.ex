defmodule FatEcto.FatHospitalDoctor do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "fat_hospitals_doctors" do
    belongs_to(:fat_doctor, FatEcto.FatDoctor, primary_key: true)
    belongs_to(:fat_hospital, FatEcto.FatHospital, primary_key: true)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :fat_doctor_id,
      :fat_hospital_id
    ])
    |> validate_required([:fat_doctor_id, :fat_hospital_id])
    |> foreign_key_constraint(:fat_doctor_id)
    |> foreign_key_constraint(:fat_hospital_id)
  end
end
