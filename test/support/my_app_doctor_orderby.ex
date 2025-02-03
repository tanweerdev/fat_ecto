defmodule MyApp.DoctorOrderby do
  use FatEcto.FatQuery.Sortable,
    sortable_fields: %{
      "email" => "*",
      "phone" => "$asc"
    },
    overrideable_fields: []
end
