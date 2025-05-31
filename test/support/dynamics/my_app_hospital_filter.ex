defmodule FatEcto.Dynamics.MyApp.HospitalFilter do
  use FatEcto.Query.Dynamics.Buildable,
    overrideable: ["name", "phone"],
    ignoreable: [
      name: ["%%", "", [], nil],
      phone: ["%%", "", [], nil]
    ]

  import Ecto.Query

  @impl true
  def override_buildable(_dynamics, "name", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable(_dynamics, "name", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable(_dynamics, "phone", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(_dynamics, "phone", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(dynamics, _, _, _) do
    dynamics
  end
end
