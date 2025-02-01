defmodule MyApp.DoctorFilter do
  use FatEcto.FatQuery.Whereable,
    filterable_fields: %{
      "email" => ["$equal", "$like"]
    },
    overrideable_fields: ["phone"],
    ignoreable_fields_values: %{
      "email" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }

  import Ecto.Query
  @impl FatEcto.FatQuery.Whereable

  def override_whereable(query, "phone", "$ilike", compare_with) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^compare_with))
  end

  def override_whereable(query, _, _, _) do
    query
  end
end
