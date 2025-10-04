defmodule FatEcto.Query.DoctorQueryBuilder do
  use FatEcto.Query.Buildable,
    filterable: [
      email: [
        "$equal",
        "$LiKE",
        "$NOT_eQUAL",
        "$Not_LIKE",
        "$ilike",
        "$in",
        "$Not_ILIKE",
        "$NOT_in",
        "$NOT_null",
        "$Null"
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
