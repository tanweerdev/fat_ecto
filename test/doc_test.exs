defmodule DocTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatEcto.FatPatient)
    :ok
  end

  doctest FatEcto.Query.Dynamics.BtwInContains
  doctest FatEcto.Query.Dynamics.GtLtEq
  doctest FatEcto.Query.Dynamics.Like
  # doctest FatEcto.Dynamics.FatNotDynamics
  doctest FatEcto.Query.Dynamics.Builder
  doctest FatEcto.Query.OperatorApplier
  # doctest FatEcto.SharedHelper
  doctest FatEcto.Sort.Sorter
  doctest FatEcto.Sample.Pagination
  doctest FatEcto.Sort.Helper
  doctest FatEcto.DoctorSortBuilder
  doctest FatEcto.Query.Helper
  doctest FatEcto.DoctorDynamicsBuilder
end
