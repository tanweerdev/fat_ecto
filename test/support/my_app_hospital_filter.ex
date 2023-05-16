defmodule MyApp.HospitalFilter do
  use FatEcto.FatQuery.Filterable,
    fields_allowed: %{},
    fields_not_allowed: %{
      "name" => "*",
      "phone" => "$ilike"
    },
    ignoreable_fields_values: %{
      "name" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }
end
