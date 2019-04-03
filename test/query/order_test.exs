defmodule Query.OrderTest do
  use ExUnit.Case
  import MyApp.Query
  import Ecto.Query

  test "returns the query where field is desc " do
    opts = %{
      "$order" => %{"rating" => "$desc"}
    }

    expected = from(h in FatEcto.FatHospital, order_by: [desc: h.rating])

    result = build(FatEcto.FatHospital, opts)
    assert inspect(result) == inspect(expected)
  end

  test "returns the query where field is asc " do
    opts = %{
      "$order" => %{"appointments_count" => "$asc"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [asc: p.appointments_count])

    result = build(FatEcto.FatPatient, opts)
    assert inspect(result) == inspect(expected)
  end
end
