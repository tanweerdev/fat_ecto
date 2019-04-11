defmodule FatEcto.FatRoom do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "fat_rooms" do
    field(:name, :string)
    field(:purpose, :string)
    field(:description, :string)
    field(:floor, :integer)
    field(:is_active, :boolean)

    belongs_to(:fat_hospital, FatEcto.FatHospital)
    has_many(:fat_beds, FatEcto.FatBed)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name,
      :purpose,
      :description,
      :floor,
      :is_active
    ])
  end
end
