defmodule DocTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatEcto.FatPatient)
    :ok
  end

  # doctest MyApp.Query, import: true, except: [fetch: 2, paginate: 2]

  # doctest Paginator
  doctest SanitizeRecord

  # doctest FatEcto.FatQuery.FatWhere
  # doctest FatEcto.FatQuery.FatOrderBy
  # doctest FatEcto.FatQuery.FatDynamics
  # doctest FatEcto.FatQuery.FatNotDynamics
  # doctest FatEcto.FatQuery.FatGroupBy
  # doctest FatEcto.FatQuery.FatInclude
  # doctest FatEcto.FatQuery.FatAggregate
  # doctest FatEcto.FatQuery.FatDistinct
  # doctest FatEcto.FatQuery.FatJoin
end
