defmodule MyApp.HospitalOrderby do
  import Ecto.Query

  use FatEcto.FatSortable,
    sortable: [date_of_birth: "$ASC", rating: "*"],
    overrideable: ["name", "phone"]

  def override_sortable(query, "name", "$ASC") do
    order_by(query, [r], asc: r.name)
  end

  def override_sortable(query, "phone", "$DESC") do
    order_by(query, [r], desc: r.phone)
  end

  def override_sortable(query, _, _), do: query
end
