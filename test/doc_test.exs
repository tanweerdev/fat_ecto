defmodule DocTest do
  use ExUnit.Case, async: true

  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(FatEcto.Repo)
    Sandbox.mode(FatEcto.Repo, {:shared, self()})
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
  doctest FatEcto.Sort.Helper
  doctest FatEcto.DoctorSortBuilder
  doctest FatEcto.Query.Helper
  doctest FatEcto.DoctorDynamicsBuilder
end
