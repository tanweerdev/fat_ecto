defmodule FatEcto.Context do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "contexts" do
    field(:name, :string)
    field(:purpose, :string)
    field(:description, :string)
    field(:is_active, :boolean)
    has_many(:siblings, FatEcto.Sibling)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name,
      :purpose,
      :description,
      :is_active
    ])
  end
end
