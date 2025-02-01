defmodule MyApp.HospitalFilter do
  use FatEcto.FatQuery.Whereable,
    filterable_fields: %{},
    overrideable_fields: ["name", "phone"],
    ignoreable_fields_values: %{
      "name" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }

  import Ecto.Query

  @impl true
  def override_whereable(query, "name", "$ilike", compare_with) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.name), ^compare_with))
  end

  def override_whereable(query, "name", "$like", compare_with) do
    where(query, [r], like(fragment("(?)::TEXT", r.name), ^compare_with))
  end

  def override_whereable(query, "phone", "$ilike", compare_with) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^compare_with))
  end

  def override_whereable(query, "phone", "$like", compare_with) do
    where(query, [r], like(fragment("(?)::TEXT", r.phone), ^compare_with))
  end

  def override_whereable(query, _, _, _) do
    query
  end
end
