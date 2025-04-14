defmodule FatEcto.Query.MyApp.DoctorQuery do
  use FatEcto.Builder.FatQueryBuildable,
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

  @impl FatEcto.Builder.FatQueryBuildable
  def override_buildable(query, "phone", "$ILIKE", value) do
    IO.inspect("override_buildable callback called")
    IO.inspect("query: #{inspect(query)}")
    IO.inspect("value: #{inspect(value)}")
    from(q in query, where: ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(query, "phone", "$LIKE", value) do
    from(q in query, where: like(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(query, _, _, _) do
    IO.inspect("override_buildable callback called but not matched")
    query
  end
end
