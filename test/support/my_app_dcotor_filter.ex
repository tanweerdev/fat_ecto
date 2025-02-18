defmodule Fat.DoctorFilter do
  use FatEcto.FatQuery.Whereable,
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
  @impl FatEcto.FatQuery.Whereable

  def override_whereable(dynamics, "phone", "$ILIKE", value) do
    dynamics and dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_whereable(dynamics, "phone", "$LIKE", value) do
    dynamics and dynamic([q], like(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_whereable(dynamics, _, _, _) do
    dynamics
  end
end
