defmodule Fat.DoctorOrderby do
  use FatEcto.FatSortable,
    sortable_fields: %{
      "email" => "*",
      "phone" => "$ASC"
    },
    overrideable_fields: []
end
