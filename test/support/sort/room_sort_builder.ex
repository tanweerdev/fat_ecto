defmodule FatEcto.RoomSortBuilder do
  use FatEcto.Sort.Sortable,
    overrideable: ["phone", "name"]

  import Ecto.Query

  def override_sortable("name", "$ASC") do
    {:asc, dynamic([r], r.name)}
  end

  def override_sortable("phone", "$DESC") do
    {:desc, dynamic([r], r.phone)}
  end

  def override_sortable(_, _), do: nil
end
