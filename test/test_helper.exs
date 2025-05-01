ExUnit.start(exclude: :skip)
FatEcto.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, :manual)
