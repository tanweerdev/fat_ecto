defmodule Utils.MapTest do
  use ExUnit.Case
  import FatUtils.Map

  test "has all keys" do
    map = %{name: "John", phone: "123456", address: "123 main bullavord"}
    keys = [:name, :phone]
    assert has_all_keys?(map, keys) == true

    keys = [:name, :designation]
    assert has_all_keys?(map, keys) == false
  end

  test "has all values equal to" do
    map = %{name: "John", phone: "123456", address: "123 main bullavord"}
    keys = [:name]
    equal_to = "John"
    assert has_all_val_equal_to?(map, keys, equal_to) == true

    keys = [:name, :designation]
    equal_to = "John"

    assert has_all_val_equal_to?(map, keys, equal_to) == false
  end

  test "has any keys" do
    map = %{name: "John", phone: "123456", address: "123 main bullavord"}
    keys = [:name]
    assert has_any_of_keys?(map, keys) == true

    keys = [:work]

    assert has_any_of_keys?(map, keys) == false
  end

  test "deep merge" do
    map_1 = %{name: "John", phone: "123456", address: "123 main bullavord"}
    map_2 = %{last_name: "Doe", designation: "engineer", home_address: "123 main bullavord"}

    assert deep_merge(map_1, map_2) ==
             %{
               address: "123 main bullavord",
               designation: "engineer",
               home_address: "123 main bullavord",
               last_name: "Doe",
               name: "John",
               phone: "123456"
             }
  end

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
