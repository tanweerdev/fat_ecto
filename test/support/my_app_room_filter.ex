defmodule Fat.RoomFilter do
  use FatEcto.FatQuery.Whereable,
    filterable_fields: %{},
    overrideable_fields: ["name", "phone", "purpose", "description"],
    ignoreable_fields_values: %{
      "name" => "%%",
      "phone" => "%%",
      "purpose" => [[], %{"$IN" => []}],
      "description" => [nil, %{"$EQUAL" => nil}]
    }

  import Ecto.Query
  @impl FatEcto.FatQuery.Whereable

  def override_whereable(_dynamics, "phone", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_whereable(_dynamics, "name", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_whereable(_dynamics, "name", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_whereable(_dynamics, "description", "$EQUAL", value) do
    dynamic([q], q.description == ^value)
  end

  def override_whereable(_dynamics, "purpose", "$IN", values) when is_list(values) do
    dynamic([q], q.purpose in ^values)
  end

  def override_whereable(dynamics, _, _, _) do
    dynamics
  end
end
