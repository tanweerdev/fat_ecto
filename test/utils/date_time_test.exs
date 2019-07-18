defmodule Utils.DateTimeTest do
  use FatEcto.ConnCase
  import FatUtils.DateTime

  test "parse! integer datetime" do
    assert inspect(parse!(1_464_096_368)) == "~U[2016-05-24 13:26:08Z]"
  end

  test "parse! integer datetime with microseconds" do
    assert inspect(parse!(1_432_560_368_868_569)) == "~U[2015-05-25 13:26:08.868569Z]"
  end

  test "parse! binary datetime " do
    assert inspect(parse!("2015-01-23T23:50:07Z")) == "~U[2015-01-23 23:50:07Z]"
  end

  test "parse integer datetime" do
    assert inspect(parse(1_464_096_368)) == "{:ok, ~U[2016-05-24 13:26:08Z]}"
  end

  test "parse integer datetime with microseconds" do
    assert inspect(parse(1_432_560_368_868_569)) == "{:ok, ~U[2015-05-25 13:26:08.868569Z]}"
  end

  test "parse binary datetime " do
    assert inspect(parse("2015-01-23T23:50:07Z")) == "{:ok, ~U[2015-01-23 23:50:07Z]}"
  end
end
