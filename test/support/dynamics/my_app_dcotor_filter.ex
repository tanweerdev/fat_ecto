defmodule FatEcto.Dynamics.MyApp.DoctorFilter do
  use FatEcto.Dynamics.FatBuildable,
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
  @impl FatEcto.Dynamics.FatBuildable
  # TODO: also support `field.EQUAL => value` instead of accepting just map eg `field => {"$EQUAL" => value}`
  # You can use either dot . or colon : to separate field and operator

  def override_buildable(_dynamics, "phone", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(_dynamics, "phone", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_whereable(dynamics, _, _, _) do
    dynamics
  end
end
