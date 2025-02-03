defmodule FatEcto.FatQuery.WhereableHelperTest do
  use FatEcto.ConnCase
  alias FatEcto.FatQuery.WhereableHelper

  describe "remove_ignoreable_fields/2" do
    test "removes fields with ignoreable values" do
      where_params = %{
        "name" => %{"$not_ilike" => "%DJ%"},
        "$or" => %{
          "location" => %{"$like" => "%main%"},
          "address" => %{"$ilike" => "%123%"},
          "rating" => %{"$lt" => 3},
          "total_staff" => %{"$gt" => 2}
        }
      }

      ignoreable_fields_values = %{
        "email" => ["%%", "", [], nil],
        "phone" => ["%%", "", [], nil],
        "location" => ""
      }

      assert WhereableHelper.remove_ignoreable_fields(where_params, ignoreable_fields_values) == %{
               "name" => %{"$not_ilike" => "%DJ%"},
               "$or" => %{
                 "address" => %{"$ilike" => "%123%"},
                 "rating" => %{"$lt" => 3},
                 "total_staff" => %{"$gt" => 2},
                 "location" => %{"$like" => "%main%"}
               }
             }
    end

    test "handles nested $or structures" do
      where_params = %{
        "$or" => %{
          "email" => %{"$like" => "%%"},
          "name" => %{"$eq" => "John"},
          "phone" => %{"$eq" => nil}
        }
      }

      ignoreable_fields_values = %{
        "email" => ["%%", "", [], nil],
        "phone" => ["%%", "", [], nil],
        "location" => ""
      }

      assert WhereableHelper.remove_ignoreable_fields(where_params, ignoreable_fields_values) == %{
               "$or" => %{
                 "name" => %{"$eq" => "John"}
               }
             }
    end
  end

  describe "filter_filterable_fields/2" do
    test "filters fields based on filterable_fields" do
      params = %{
        "name" => %{"$not_ilike" => "%DJ%"},
        "$or" => %{
          "location" => %{"$like" => "%main%"},
          "address" => %{"$ilike" => "%123%"},
          "rating" => %{"$lt" => 3},
          "total_staff" => %{"$gt" => 2}
        }
      }

      filterable_fields = %{
        "email" => ["$equal", "$like"],
        "name" => "*",
        "location" => "*"
      }

      assert WhereableHelper.filter_filterable_fields(params, filterable_fields) == %{
               "name" => %{"$not_ilike" => "%DJ%"},
               "$or" => %{
                 "location" => %{"$like" => "%main%"}
               }
             }
    end
  end

  describe "filter_overrideable_fields/3" do
    test "filters overrideable fields and ignores ignoreable values" do
      params = %{
        "email" => %{"$like" => "test@example.com"},
        "phone" => %{"$eq" => "1234567890"},
        "location" => %{"$ilike" => ""}
      }

      overrideable_fields = ["email", "phone"]

      ignoreable_fields_values = %{
        "email" => ["%%", "", [], nil],
        "phone" => ["%%", "", [], nil],
        "location" => ""
      }

      assert WhereableHelper.filter_overrideable_fields(params, overrideable_fields, ignoreable_fields_values) ==
               [
                 %{field: "phone", operator: "$eq", value: "1234567890"},
                 %{field: "email", operator: "$like", value: "test@example.com"}
               ]
    end
  end
end
