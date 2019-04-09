defmodule FatEcto.Sibling do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "siblings" do
    field(:name, :string)
    field(:purpose, :string)
    field(:description, :string)
    field(:phone, :string)
    field(:is_active, :boolean)
    belongs_to(:context, FatEcto.ContextModel, foreign_key: :context_id)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name,
      :purpose,
      :description,
      :phone,
      :is_active,
      :context_id
    ])
  end
end
