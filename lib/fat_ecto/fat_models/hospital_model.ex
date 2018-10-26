defmodule FatEcto.FatHospital do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:name, :location, :phone, :address, :total_staff, :rating]

  schema "fat_hospitals" do
    field(:name, :string)
    field(:location, :string)
    field(:phone, :string)
    field(:address, :string)
    field(:total_staff, :integer)
    field(:rating, :integer)

    has_many(:fat_rooms, FatEcto.FatRoom)

    many_to_many(:fat_doctors, FatEcto.FatDoctor, join_through: FatEcto.FatHospitalDoctor)
  end

  def changeset(data) when is_map(data) do
    %__MODULE__{}
    |> cast(data, @fields)
    |> apply_changes()
  end
end
