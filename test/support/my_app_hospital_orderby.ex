defmodule MyApp.HospitalOrderby do
  import Ecto.Query

  use FatEcto.FatQuery.Sortable,
    sortable_fields: %{"date_of_birth" => "$asc", "rating" => "*"},
    overrideable_fields: ["name", "phone"]

  def override_sortable(query, "name", "$asc") do
    order_by(query, [r], asc: r.name)
  end

  def override_sortable(query, "phone", "$desc") do
    order_by(query, [r], desc: r.phone)
  end

  def override_sortable(query, _, _), do: query
end
