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

  def override_whereable(nil, field, operator, value) do
    override_whereable(true, field, operator, value)
  end

  def override_whereable(dynamics, "phone", "$ILIKE", value) do
    dynamics and dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_whereable(dynamics, "name", "$LIKE", value) do
    dynamics and dynamic([q], like(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_whereable(dynamics, "name", "$ILIKE", value) do
    dynamics and dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_whereable(dynamics, "description", "$EQUAL", value) do
    dynamics and dynamic([q], q.description == ^value)
  end

  def override_whereable(dynamics, "purpose", "$IN", values) when is_list(values) do
    dynamics and dynamic([q], q.purpose in ^values)
  end

  def override_whereable(dynamics, _, _, _) do
    dynamics
  end
end
