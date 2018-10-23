defmodule Query.OrderTest do
  use ExUnit.Case
  import FatEcto.FatQuery  
  import Ecto.Query

  test "returns the query where field is desc " do
    opts = %{
      "$order" => %{"rating" => "$desc"}
    }

    expected = from(h in FatEcto.FatHospital , order_by: [desc: h.rating])

    assert inspect(build(FatEcto.FatHospital , opts)) == inspect(expected)
  end

  test "returns the query where field is asc " do
    opts = %{
      "$order" => %{"appointments_count" => "$asc"}
    }

    expected = from(p in FatEcto.FatPatient, order_by: [asc: p.appointments_count])

    assert inspect(build(FatEcto.FatPatient, opts)) == inspect(expected)
  end
end
