defmodule FatEcto.FatHospitalFilter do
  use FatEcto.Dynamics.FatBuildable,
    filterable_fields: %{},
    overrideable_fields: ["name", "phone"],
    ignoreable_fields_values: %{
      "name" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }

  import Ecto.Query

  @impl true
  def override_whereable(_dynamics, "name", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_whereable(_dynamics, "name", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.name), ^value))
  end

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
