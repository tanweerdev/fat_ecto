defmodule FatEcto.Dynamics.FatBuildableHelperTest do
  use FatEcto.ConnCase
  alias FatEcto.Dynamics.FatBuildableHelper

  describe "remove_ignoreable_fields/2" do
    test "removes fields with ignoreable values" do
      where_params = %{
        "name" => "John",
        "email" => "",
        "phone" => nil,
        "age" => %{"$GT" => 18}
      }

      ignoreable_fields_values = %{
        "email" => ["", "%%", nil],
        "phone" => [nil]
      }

      result = FatBuildableHelper.remove_ignoreable_fields(where_params, ignoreable_fields_values)

      assert result == %{
               "name" => "John",
               "age" => %{"$GT" => 18}
             }
    end

    test "does not remove fields with non-ignoreable values" do
      where_params = %{
        "name" => "John",
        "email" => "test@example.com",
        "age" => %{"$GT" => 18}
      }

      ignoreable_fields_values = %{
        "email" => ["", "%%", nil]
      }

      result = FatBuildableHelper.remove_ignoreable_fields(where_params, ignoreable_fields_values)

      assert result == %{
               "name" => "John",
               "email" => "test@example.com",
               "age" => %{"$GT" => 18}
             }
    end
  end

  describe "filter_filterable_fields/2" do
    test "filters fields based on allowed operators" do
      where_params = %{
        "name" => %{"$ILIKE" => "%John%"},
        "age" => %{"$GT" => 18},
        "email" => %{"$EQUAL" => "test@example.com"}
      }

      filterable_fields = [
        :name,
        :age
      ]

      overideable_fields = []

      result =
        FatBuildableHelper.filter_filterable_fields(where_params, filterable_fields, overideable_fields)

      assert result == %{
               "name" => %{"$ILIKE" => "%John%"},
               "age" => %{"$GT" => 18}
             }
    end

    test "filters fields for complex params" do
      where_params = %{
        "$OR" => [
          %{
            "name" => %{"$ILIKE" => "%John%"},
            "$OR" => [
              %{"rating" => %{"$GT" => 18}},
              %{"location" => "New York"}
            ]
          },
          %{
            "start_date" => "2023-01-01",
            "$AND" => [
              %{"rating" => %{"$GT" => 4}},
              %{"email" => "fat_ecto@example.com"}
            ]
          }
        ]
      }

      expected = %{
        "$OR" => [
          %{
            "$OR" => [
              %{"rating" => %{"$GT" => 18}},
              %{"location" => %{"$EQUAL" => "New York"}}
            ],
            "name" => %{"$ILIKE" => "%John%"}
          },
          %{
            "$AND" => [
              %{"rating" => %{"$GT" => 4}},
              %{"email" => %{"$EQUAL" => "fat_ecto@example.com"}}
            ],
            "start_date" => %{"$EQUAL" => "2023-01-01"}
          }
        ]
      }

      filterable_fields = [
        email: "*",
        name: "*",
        rating: "*",
        start_date: "*",
        location: "*"
      ]

      overideable_fields = ["phone"]

      result =
        FatBuildableHelper.filter_filterable_fields(where_params, filterable_fields, overideable_fields)

      assert result == expected
    end

    test "filters fields for complex params with some fields not allowed" do
      where_params = %{
        "$OR" => [
          %{
            "name" => %{"$ILIKE" => "%John%"},
            "$OR" => [
              %{"rating" => %{"$GT" => 18}},
              %{"location" => "New York"}
            ]
          },
          %{
            "start_date" => "2023-01-01",
            "$AND" => [
              %{"rating" => %{"$GT" => 4}},
              %{"email" => "fat_ecto@example.com"}
            ]
          }
        ]
      }

      expected = %{
        "$OR" => [
          %{"name" => %{"$ILIKE" => "%John%"}},
          %{"$AND" => [%{"email" => %{"$EQUAL" => "fat_ecto@example.com"}}]}
        ]
      }

      filterable_fields = [
        email: "*",
        name: "*"
      ]

      overideable_fields = ["phone"]

      result =
        FatBuildableHelper.filter_filterable_fields(where_params, filterable_fields, overideable_fields)

      assert result == expected
    end

    test "filters fields for complex params with $OR as map" do
      where_params = %{
        "$OR" => [
          %{
            "name" => %{"$ILIKE" => "%John%"},
            "$OR" => %{
              "rating" => %{"$GT" => 18},
              "location" => "New York"
            }
          },
          %{
            "start_date" => "2023-01-01",
            "$AND" => [
              %{"rating" => %{"$GT" => 4}},
              %{"email" => "fat_ecto@example.com"}
            ]
          }
        ]
      }

      expected = %{
        "$OR" => [
          %{"name" => %{"$ILIKE" => "%John%"}},
          %{"$AND" => [%{"email" => %{"$EQUAL" => "fat_ecto@example.com"}}]}
        ]
      }

      filterable_fields = [
        email: "*",
        name: "*"
      ]

      overideable_fields = ["phone"]

      result =
        FatBuildableHelper.filter_filterable_fields(where_params, filterable_fields, overideable_fields)

      assert result == expected
    end

    test "handles direct comparisons" do
      where_params = %{
        "name" => "John",
        "age" => 25
      }

      filterable_fields = [
        name: ["$EQUAL"],
        age: "*"
      ]

      overideable_fields = []

      result =
        FatBuildableHelper.filter_filterable_fields(where_params, filterable_fields, overideable_fields)

      assert result == %{
               "name" => %{"$EQUAL" => "John"},
               "age" => %{"$EQUAL" => 25}
             }
    end
  end
end
