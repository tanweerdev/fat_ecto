defmodule Utils.IntegerTest do
  use ExUnit.Case
  import FatUtils.Integer

  test "parse integer/integer string with returning tuple" do
    assert parse(12) == {:ok, 12}
    assert parse("12r") == {:ok, 12}
    assert parse("rrrr") == {:error, nil}
  end

  test "parse integer/integer string" do
    assert parse!(14) == 14
    assert parse!("14rtyt") == 14
    assert parse!("rrrr") == nil
  end
end
