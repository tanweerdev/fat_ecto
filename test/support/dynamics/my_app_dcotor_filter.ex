defmodule FatEcto.Dynamics.MyApp.DoctorFilter do
  use FatEcto.Dynamics.FatBuildable,
    filterable_fields: %{
      "email" => [
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
      "name" => "*",
      "rating" => "*",
      "start_date" => "*",
      "location" => "*"
    },
    overrideable_fields: ["phone"],
    ignoreable_fields_values: %{
      "email" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }

  import Ecto.Query
  @impl FatEcto.Dynamics.FatBuildable

  def override_whereable(_dynamics, "phone", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_whereable(_dynamics, "phone", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_whereable(dynamics, _, _, _) do
    dynamics
  end
end
