defmodule FatEcto.HospitalSortBuilder do
  import Ecto.Query

  use FatEcto.Sort.Sortable,
    sortable: [date_of_birth: "$ASC", rating: "*"],
    overrideable: ["name", "phone"]

  def override_sortable("name", "$ASC") do
    {:asc, dynamic([r], r.name)}
  end

  def override_sortable("phone", "$DESC") do
    {:desc, dynamic([r], r.phone)}
  end

  def override_sortable(_, _), do: nil
end
