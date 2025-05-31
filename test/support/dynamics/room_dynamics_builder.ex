defmodule FatEcto.Dynamics.MyApp.RoomFilter do
  use FatEcto.Query.Dynamics.Buildable,
    filterable: [],
    overrideable: ["name", "phone", "purpose", "description"],
    ignoreable: [
      name: "%%",
      phone: "%%",
      purpose: [[], %{"$IN" => []}],
      description: [nil, %{"$EQUAL" => nil}]
    ]

  import Ecto.Query
  @impl FatEcto.Query.Dynamics.Buildable

  def override_buildable(_dynamics, "phone", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(_dynamics, "name", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable(_dynamics, "name", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable(_dynamics, "description", "$EQUAL", value) do
    dynamic([q], q.description == ^value)
  end

  def override_buildable(_dynamics, "purpose", "$IN", values) when is_list(values) do
    dynamic([q], q.purpose in ^values)
  end

  def override_buildable(dynamics, _, _, _) do
    dynamics
  end
end
