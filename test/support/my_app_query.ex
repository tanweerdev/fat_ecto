defmodule MyApp.Query do
  use FatEcto.FatQuery,
    otp_app: :fat_ecto,
    max_limit: 103,
    default_limit: 34,
    blacklist_params: [
      {:fat_rooms, ["description"]},
      {:fat_beds, ["is_active"]},
      {:fat_hospitals, ["phone"]},
      {:fat_doctors, ["name"]},
      {:fat_patients, ["date_of_birth"]}
    ]
end
