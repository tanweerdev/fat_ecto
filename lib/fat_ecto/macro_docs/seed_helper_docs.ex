defmodule SeedHelper do
  @moduledoc """
   Seed helper is used to seed data inside your migrations. It maps csv data to the table coloumns. You can specify `seed_base_path` inside your fat_ecto config and use it inside your module.
   ```
   use FatUtils.SeedHelper, otp_app: :app_name, seed_base_path: "base_path_for_your_seed_directory"
   ```

  """
  # use FatUtils.SeedHelper, otp_app: :fat_ecto, seed_base_path: "priv/csvs"
end
