defmodule MyApp.Query do
  use FatEcto.FatQuery,
    otp_app: :fat_ecto,
    max_limit: 103,
    default_limit: 34,
    repo: [module: FatEcto.Repo]
end
