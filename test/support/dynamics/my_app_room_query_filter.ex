defmodule FatEcto.Query.MyApp.RoomQuery do
  use FatEcto.Builder.FatQueryBuildable,
    filterable: [],
    overrideable: ["name", "phone", "purpose", "description"],
    ignoreable: [
      name: "%%",
      phone: "%%",
      purpose: [[], %{"$IN" => []}],
      description: [nil, %{"$EQUAL" => nil}]
    ]

  import Ecto.Query

  @impl FatEcto.Builder.FatQueryBuildable
  def override_buildable(query, "phone", "$ILIKE", value) do
    from(q in query, where: ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(query, "name", "$LIKE", value) do
    from(q in query, where: like(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable(query, "name", "$ILIKE", value) do
    from(q in query, where: ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable(query, "description", "$EQUAL", value) do
    from(q in query, where: q.description == ^value)
  end

  def override_buildable(query, "purpose", "$IN", values) when is_list(values) do
    from(q in query, where: q.purpose in ^values)
  end

  def override_buildable(query, _, _, _) do
    query
  end
end
