defmodule FatEcto.AliasSortBuilder do
  @moduledoc false

  use FatEcto.Sort.Sortable,
    sortable: [
      id: "*",
      total_staff: ["$ASC", "$DESC"],
      hospital_name: {:name, "*"},
      hospital_location: {:location, ["$ASC", "$DESC"]},
      fat_rooms: [
        floor: "*",
        is_active: ["$ASC", "$DESC"],
        room_name: {:name, "*"}
      ],
      fat_doctors: [
        experience_years: "*",
        doctor_name: {:name, "*"},
        doctor_rating: {:rating, ["$ASC", "$DESC"]}
      ]
    ],
    overrideable: ["custom_sort"]

  import Ecto.Query

  @impl true
  def override_sortable("custom_sort", "$ASC") do
    {:asc, dynamic([h], h.rating)}
  end

  def override_sortable("custom_sort", "$DESC") do
    {:desc, dynamic([h], h.rating)}
  end

  def override_sortable(_field, _operator), do: nil
end
