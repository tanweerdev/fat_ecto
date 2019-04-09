ExUnit.start(exclude: :failing)
FatEcto.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, :manual)
