defmodule MyApp.RoomOrderby do
  use FatEcto.FatQuery.Sortable,
    allowed_fields: %{},
    customizable_fields: %{
      "phone" => "$desc",
      "name" => "$asc"
    }

  import Ecto.Query

  def custom_orderby_fallback(query, "name", "$asc") do
    order_by(query, [r], asc: r.name)
  end

  def custom_orderby_fallback(query, "phone", "$desc") do
    order_by(query, [r], desc: r.phone)
  end

  def custom_orderby_fallback(query, _, _), do: query
end
