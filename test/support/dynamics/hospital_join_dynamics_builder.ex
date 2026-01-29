defmodule FatEcto.HospitalJoinDynamicsBuilder do
  @moduledoc """
  Test module for join filter functionality using existing FatEcto schemas.

  Uses FatHospital model with:
  - Direct filters on the hospitals table (name, location, rating, total_staff)
  - Join filters on fat_rooms table via :fat_rooms binding (floor, is_active, purpose)
  - Join filters on fat_doctors table via :fat_doctors binding (experience_years, designation)
  - Overrideable fields (active_hospital, search)

  Usage example with actual query:

      FatHospital
      |> join(:left, [h], r in assoc(h, :fat_rooms), as: :fat_rooms)
      |> join(:left, [h], d in assoc(h, :fat_doctors), as: :fat_doctors)
      |> where(^dynamics)
  """

  use FatEcto.Query.Dynamics.Buildable,
    filterable: [
      # Direct filters on the hospitals table
      name: ["$ILIKE", "$EQUAL"],
      location: ["$ILIKE", "$EQUAL"],
      rating: ["$GTE", "$LTE", "$EQUAL", "$GT", "$LT"],
      total_staff: ["$GTE", "$LTE", "$GT", "$LT"],
      # Join filter on :fat_rooms binding (FatRoom association)
      fat_rooms: [
        floor: ["$EQUAL", "$GTE", "$LTE", "$IN"],
        is_active: ["$EQUAL"],
        purpose: ["$ILIKE", "$EQUAL"]
      ],
      # Join filter on :fat_doctors binding (FatDoctor association)
      fat_doctors: [
        experience_years: ["$GTE", "$LTE", "$EQUAL", "$GT", "$LT"],
        designation: ["$ILIKE", "$EQUAL", "$IN"]
      ]
    ],
    overrideable: ["active_hospital", "search"],
    ignoreable: [
      name: ["%%", "", nil],
      location: ["%%", "", nil],
      search: ["%%", "", nil]
    ],
    default_dynamic: :return_true

  import Ecto.Query

  @impl true
  def override_buildable("active_hospital", "$EQUAL", true) do
    dynamic([h], h.total_staff > 0 and h.rating >= 3)
  end

  def override_buildable("active_hospital", "$EQUAL", false) do
    dynamic([h], h.total_staff == 0 or h.rating < 3)
  end

  def override_buildable("search", "$ILIKE", value) when is_binary(value) and value != "" do
    search_term = "%#{value}%"
    dynamic([h], ilike(h.name, ^search_term) or ilike(h.location, ^search_term))
  end

  def override_buildable(_, _, _), do: nil
end
