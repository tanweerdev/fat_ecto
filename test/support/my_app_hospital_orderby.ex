defmodule MyApp.HospitalOrderby do
  use FatEcto.FatQuery.Sortable,
    sortable_fields: %{},
    overrideable_fields: ["name", "phone"]
end
