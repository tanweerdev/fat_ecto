defmodule FatEcto.FatBed do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "fat_beds" do
    field(:name, :string)
    field(:purpose, :string)
    field(:description, :string)
    field(:is_active, :boolean)
    belongs_to(:fat_room, FatEcto.FatRoom, foreign_key: :fat_room_id)
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [
      :name,
      :purpose,
      :description,
      :is_active,
      :fat_room_id
    ])
  end
end
