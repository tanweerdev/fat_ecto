defmodule FatEcto.ConnCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto.Changeset
      import Ecto.Query
      import FatEcto.Factory

      alias FatEcto.Repo
      alias MyApp.DoctorFilter
      alias MyApp.DoctorOrderby
      alias MyApp.HospitalFilter
      alias MyApp.HospitalOrderby
      alias MyApp.PatientOrderby
      alias MyApp.RoomFilter
      alias MyApp.RoomOrderby
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatEcto.FatPatient)
    :ok
  end
end
