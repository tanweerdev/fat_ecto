defmodule Fat.RoomOrderby do
  use FatEcto.FatSortable,
    overrideable_fields: ["phone", "name"]

  import Ecto.Query

  def override_sortable(query, "name", "$ASC") do
    order_by(query, [r], asc: r.name)
  end

  def override_sortable(query, "phone", "$DESC") do
    order_by(query, [r], desc: r.phone)
  end

  def override_sortable(query, _, _), do: query
end
