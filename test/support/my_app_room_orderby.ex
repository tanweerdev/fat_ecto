defmodule MyApp.RoomOrderby do
  use FatEcto.FatQuery.Sortable,
    overrideable_fields: ["phone", "name"]

  import Ecto.Query

  def override_sortable(query, "name", "$asc") do
    order_by(query, [r], asc: r.name)
  end

  def override_sortable(query, "phone", "$desc") do
    order_by(query, [r], desc: r.phone)
  end

  def override_sortable(query, _, _), do: query
end
