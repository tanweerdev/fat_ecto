defmodule MyApp.RoomFilter do
  use FatEcto.FatQuery.Whereable,
    filterable_fields: %{},
    overrideable_fields: ["name", "phone", "purpose", "description"],
    ignoreable_fields_values: %{
      "name" => "%%",
      "phone" => "%%",
      "purpose" => [[], %{"$in" => []}],
      "description" => [nil, %{"$equal" => nil}]
    }

  import Ecto.Query
  @impl FatEcto.FatQuery.Whereable
  def override_whereable(query, "phone", "$ilike", value) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^value))
  end

  def override_whereable(query, "name", "$like", value) do
    where(query, [r], like(fragment("(?)::TEXT", r.name), ^value))
  end

  def override_whereable(query, "name", "$ilike", value) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.name), ^value))
  end

  def override_whereable(query, "description", "$equal", value) do
    where(query, [r], r.description == ^value)
  end

  def override_whereable(query, "purpose", "$in", value) when is_list(value) do
    where(query, [r], r.purpose in ^value)
  end

  def override_whereable(query, _, _, _) do
    query
  end
end
