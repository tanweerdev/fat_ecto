defmodule MyApp.DoctorFilter do
  use FatEcto.FatQuery.Filterable,
    fields_allowed: %{
      "email" => ["$equal", "$like"]
    },
    fields_not_allowed: %{
      "phone" => "*"
    }
end
