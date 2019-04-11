defmodule Utils.RecordUtils do
  use ExUnit.Case
  import FatEcto.TestRecordUtils

  test "sanitize_map" do
    record = FatEcto.FatHospital.changeset(%{name: "saint marry", location: "brazil", phone: "34756"})

    assert sanitize_map(record) == %{
             address: nil,
             id: nil,
             location: "brazil",
             name: "saint marry",
             phone: "34756",
             rating: nil,
             total_staff: nil
           }
  end

  test "sanitize_map as a list" do
    record = FatEcto.FatHospital.changeset(%{name: "saint marry", location: "brazil", phone: "34756"})

    assert sanitize_map([record]) == [
             %{
               address: nil,
               id: nil,
               location: "brazil",
               name: "saint marry",
               phone: "34756",
               rating: nil,
               total_staff: nil
             }
           ]
  end
end
