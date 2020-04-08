defmodule Utils.RecordUtils do
  use FatEcto.ConnCase
  import FatEcto.TestRecordUtils

  test "sanitize" do
    record =
      FatEcto.FatHospital.changeset(%FatEcto.FatHospital{}, %{
        name: "saint marry",
        location: "brazil",
        phone: "34756"
      })

    {:ok, record} = Repo.insert(record)

    assert sanitize(record) == %{
             address: nil,
             id: record.id,
             location: "brazil",
             name: "saint marry",
             phone: "34756",
             rating: nil,
             total_staff: nil
           }
  end

  test "sanitize as a list" do
    record =
      FatEcto.FatHospital.changeset(%FatEcto.FatHospital{}, %{
        name: "saint marry",
        location: "brazil",
        phone: "34756"
      })

    {:ok, record} = Repo.insert(record)

    assert sanitize([record]) == [
             %{
               address: nil,
               id: record.id,
               location: "brazil",
               name: "saint marry",
               phone: "34756",
               rating: nil,
               total_staff: nil
             }
           ]
  end
end
