defmodule Fat.DoctorOrderby do
  use FatEcto.FatSortable,
    sortable: [
      email: "*",
      phone: "$ASC"
    ],
    overrideable: []
end
