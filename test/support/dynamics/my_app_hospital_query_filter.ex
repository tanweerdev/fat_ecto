defmodule FatEcto.Query.MyApp.HospitalQuery do
  use FatEcto.Query.Buildable,
    overrideable: ["name", "phone"],
    ignoreable: [
      name: ["%%", "", [], nil],
      phone: ["%%", "", [], nil]
    ]

  import Ecto.Query

  @impl true
  def override_buildable(query, "name", "$ILIKE", value) do
    from(q in query, where: ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable(query, "name", "$LIKE", value) do
    from(q in query, where: like(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable(query, "phone", "$ILIKE", value) do
    from(q in query, where: ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(query, "phone", "$LIKE", value) do
    from(q in query, where: like(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(query, _, _, _) do
    query
  end
end
