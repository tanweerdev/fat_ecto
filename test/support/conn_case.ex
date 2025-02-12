defmodule FatEcto.ConnCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto.Changeset
      import Ecto.Query
      import FatEcto.Factory

      alias FatEcto.Repo
      alias Fat.DoctorFilter
      alias Fat.DoctorOrderby
      alias FatEcto.FatHospitalFilter
      alias FatEcto.FatHospitalOrderby
      alias Fat.PatientOrderby
      alias Fat.RoomFilter
      alias Fat.RoomOrderby
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatEcto.FatPatient)
    :ok
  end
end
