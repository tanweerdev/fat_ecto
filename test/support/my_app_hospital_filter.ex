defmodule MyApp.HospitalFilter do
  use FatEcto.FatQuery.Filterable,
    fields_allowed: %{},
    fields_not_allowed: %{
      "name" => "*",
      "phone" => "$ilike"
    }
end
