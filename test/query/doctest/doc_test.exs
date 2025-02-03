defmodule DocTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatEcto.FatPatient)
    :ok
  end

  # doctest MyApp.Query, import: true, except: [fetch: 2, paginate: 2]
  doctest PaginatorDocs
  doctest SanitizeRecordsDocs
  # doctest FatEcto.FatQuery.FatWhere
  # doctest FatEcto.FatQuery.FatOrderBy
  # doctest FatEcto.FatQuery.FatDynamics
  # doctest FatEcto.FatQuery.FatNotDynamics
end
