defmodule FatEcto.FatRoom do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:beds, :patients, :incharge, :nurses, :level]

  schema "fat_rooms" do
    field(:beds, :integer)
    field(:patients, :integer)
    field(:incharge, :string)
    field(:nurses, :integer)
    field(:level, :integer)

    belongs_to(:hospital, FatEcto.FatHospital)
  end

  def changeset(data) when is_map(data) do
    %__MODULE__{}
    |> cast(data, @fields)
    |> apply_changes()
  end
end
