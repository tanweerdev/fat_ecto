defmodule DocTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatEcto.FatPatient)
    :ok
  end

  doctest FatEcto.Dynamics.FatDynamics
  doctest FatEcto.Dynamics.FatNotDynamics
  doctest FatEcto.Dynamics.FatDynamicsBuilder
  doctest FatEcto.Dynamics.FatOperatorHelper
  # doctest FatEcto.Utils.Changeset
  doctest FatEcto.Utils.DateTime
  doctest FatEcto.Utils.Integer
  doctest FatEcto.Utils.Map
  # doctest FatEcto.Utils.Network
  # doctest FatEcto.Utils.String
  # doctest FatEcto.Utils.Table
  doctest FatEcto.Utils.UUID
  # doctest FatEcto.FatAppContext
  doctest FatEcto.TestRecordUtils
  # doctest FatEcto.FatHelper
  doctest FatEcto.FatOrderBy
  doctest FatEcto.Sample.Pagination
  doctest FatEcto.FatSortableHelper
  doctest Fat.DoctorOrderby
  doctest FatEcto.Dynamics.FatBuildableHelper
  doctest Fat.DoctorFilter
end
