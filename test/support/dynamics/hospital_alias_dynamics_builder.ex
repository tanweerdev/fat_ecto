defmodule FatEcto.HospitalAliasDynamicsBuilder do
  @moduledoc false

  use FatEcto.Query.Dynamics.Buildable,
    filterable: [
      name: ["$ILIKE", "$EQUAL"],
      total_staff: ["$GTE", "$LTE"],
      hospital_location: {:location, ["$ILIKE", "$EQUAL"]},
      fat_rooms: [
        room_name: {:name, ["$ILIKE", "$EQUAL"]},
        floor: ["$EQUAL", "$GTE", "$LTE"],
        purpose: ["$ILIKE", "$EQUAL"]
      ],
      fat_doctors: [
        doctor_name: {:name, ["$ILIKE", "$EQUAL"]},
        doctor_rating: {:rating, ["$GTE", "$LTE"]},
        experience_years: ["$GTE", "$LTE"]
      ]
    ],
    overrideable: ["search"],
    ignoreable: [
      name: ["%%", "", nil],
      search: ["%%", "", nil]
    ],
    default_dynamic: :return_true

  import Ecto.Query

  @impl true
  def override_buildable("search", "$ILIKE", value) when is_binary(value) and value != "" do
    search_term = "%#{value}%"
    dynamic([h], ilike(h.name, ^search_term) or ilike(h.location, ^search_term))
  end

  def override_buildable(_, _, _), do: nil
end
