defmodule MyApp.PatientFilter do
  use FatEcto.FatQuery.Filterable,
    fields_allowed: %{},
    fields_not_allowed: %{},
    ignoreable_fields_values: %{
      "name" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }
end
