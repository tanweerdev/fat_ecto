defmodule Fat.DoctorOrderby do
  use FatEcto.FatQuery.Sortable,
    sortable_fields: %{
      "email" => "*",
      "phone" => "$ASC"
    },
    overrideable_fields: []
end
