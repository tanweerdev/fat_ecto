defmodule FatEcto.Query.MyApp.DoctorQuery do
  use FatEcto.Query.Buildable,
    filterable: [
      email: [
        "$EQUAL",
        "$LIKE",
        "$NOT_EQUAL",
        "$NOT_LIKE",
        "$ILIKE",
        "$IN",
        "$NOT_ILIKE",
        "$NOT_IN",
        "$NOT_NULL",
        "$NULL"
      ],
      name: "*",
      rating: "*",
      start_date: "*",
      location: "*"
    ],
    overrideable: ["phone"],
    ignoreable: [
      email: ["%%", "", [], nil],
      phone: ["%%", "", [], nil]
    ]

  import Ecto.Query

  @impl FatEcto.Query.Buildable
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
