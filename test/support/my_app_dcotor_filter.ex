defmodule MyApp.DoctorFilter do
  use FatEcto.FatQuery.Filterable,
    fields_allowed: %{
      "email" => ["$equal", "$like"]
    },
    fields_not_allowed: %{
      "phone" => "*"
    },
    ignoreable_fields_values: %{
      "email" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }
end
