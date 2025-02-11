defmodule DocTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatEcto.FatPatient)
    :ok
  end

  # doctest FatEcto.FatQuery.FatDynamics
  doctest FatEcto.FatQuery.FatNotDynamics
  # doctest FatEcto.FatQuery.Builder
  doctest FatEcto.FatQuery.OperatorHelper
  # doctest FatUtils.Changeset
  doctest FatUtils.DateTime
  doctest FatUtils.Integer
  doctest FatUtils.Map
  # doctest FatUtils.Network
  # doctest FatUtils.String
  # doctest FatUtils.Table
  doctest FatUtils.UUID
  # doctest Fat.TestContext
  doctest FatEcto.TestRecordUtils
  # doctest FatEcto.FatHelper
  doctest FatEcto.FatQuery.FatOrderBy
  doctest FatEcto.Sample.Pagination
  doctest FatEcto.FatQuery.SortableHelper
  doctest Fat.DoctorOrderby
  doctest FatEcto.FatQuery.WhereableHelper
  doctest Fat.DoctorFilter
end
