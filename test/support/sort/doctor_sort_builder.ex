defmodule FatEcto.DoctorSortBuilder do
  use FatEcto.Sort.Sortable,
    sortable: [
      email: "*",
      phone: "$ASC"
    ],
    overrideable: []
end
