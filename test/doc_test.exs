defmodule DocTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatEcto.FatPatient)
    :ok
  end

  doctest FatEcto.Dynamics.FatBtwInContainsDynamics
  doctest FatEcto.Dynamics.FatGtLtEqDynamics
  doctest FatEcto.Dynamics.FatLikeDynamics
  # doctest FatEcto.Dynamics.FatNotDynamics
  doctest FatEcto.Builder.FatDynamicsBuilder
  doctest FatEcto.Builder.FatOperatorHelper
  # doctest FatEcto.FatHelper
  doctest FatEcto.FatOrderBy
  doctest FatEcto.Sample.Pagination
  doctest FatEcto.FatSortableHelper
  doctest Fat.DoctorOrderby
  doctest FatEcto.Builder.FatHelper
  doctest FatEcto.Dynamics.MyApp.DoctorFilter
end
