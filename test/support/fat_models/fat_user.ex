defmodule FatEcto.FatUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:age, :integer)
    field(:city, :string)
    field(:status, :string)
    field(:rating, :float)
    field(:created_at, :utc_datetime)
    field(:phone, :string)
    field(:is_active, :boolean)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :age, :city, :status, :rating, :created_at, :phone, :is_active])
    |> validate_required([:name, :email])
  end
end
