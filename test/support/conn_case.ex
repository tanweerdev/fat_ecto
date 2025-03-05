defmodule FatEcto.ConnCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto.Changeset
      import Ecto.Query
      import FatEcto.Factory

      alias FatEcto.Repo
      alias FatEcto.Dynamics.MyApp.DoctorFilter
      alias Fat.DoctorOrderby
      alias FatEcto.Dynamics.MyApp.HospitalFilter
      alias FatEcto.FatHospitalOrderby
      alias Fat.PatientOrderby
      alias FatEcto.Dynamics.MyApp.RoomFilter
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
