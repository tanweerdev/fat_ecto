defmodule FatEcto.Repo do
  use Ecto.Repo,
    otp_app: :fat_ecto,
    adapter: Ecto.Adapters.Postgres
end
