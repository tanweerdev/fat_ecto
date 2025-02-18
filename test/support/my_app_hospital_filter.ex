defmodule FatEcto.FatHospitalFilter do
  use FatEcto.FatQuery.Whereable,
    filterable_fields: %{},
    overrideable_fields: ["name", "phone"],
    ignoreable_fields_values: %{
      "name" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }

  import Ecto.Query

  @impl true
  def override_whereable(nil, field, operator, value) do
    override_whereable(true, field, operator, value)
  end

  def override_whereable(dynamics, "name", "$ILIKE", value) do
    dynamics and dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_whereable(dynamics, "name", "$LIKE", value) do
    dynamics and dynamic([q], like(fragment("(?)::TEXT", q.name), ^value))
  end

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
