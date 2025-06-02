defmodule FatEcto.HospitalDynamicsBuilder do
  use FatEcto.Query.Dynamics.Buildable,
    overrideable: ["name", "phone"],
    ignoreable: [
      name: ["%%", "", [], nil],
      phone: ["%%", "", [], nil]
    ]

  import Ecto.Query

  @impl true
  def override_buildable("name", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable("name", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.name), ^value))
  end

  def override_buildable("phone", "$ILIKE", value) do
    dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable("phone", "$LIKE", value) do
    dynamic([q], like(fragment("(?)::TEXT", q.phone), ^value))
  end

  def override_buildable(_, _, _) do
    nil
  end
end
