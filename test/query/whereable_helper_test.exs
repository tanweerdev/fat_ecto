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

      filterable_fields = %{
        "name" => ["$ILIKE"],
        "age" => "*"
      }

      result = FatBuildableHelper.filter_filterable_fields(where_params, filterable_fields)

      assert result == %{
               "name" => %{"$ILIKE" => "%John%"},
               "age" => %{"$GT" => 18}
             }
    end

    test "handles direct comparisons" do
      where_params = %{
        "name" => "John",
        "age" => 25
      }

      filterable_fields = %{
        "name" => ["$EQUAL"],
        "age" => "*"
      }

      result = FatBuildableHelper.filter_filterable_fields(where_params, filterable_fields)

      assert result == %{
               "name" => %{"$EQUAL" => "John"},
               "age" => %{"$EQUAL" => 25}
             }
    end
  end

  describe "filter_overrideable_fields/3" do
    test "filters overrideable fields and ignores ignoreable values" do
      where_params = %{
        "name" => "John",
        "phone" => "",
        "email" => %{"$EQUAL" => "test@example.com"}
      }

      overrideable_fields = ["phone", "email"]

      ignoreable_fields_values = %{
        "phone" => [""]
      }

      result =
        FatBuildableHelper.filter_overrideable_fields(
          where_params,
          overrideable_fields,
          ignoreable_fields_values
        )

      assert result == [
               %{field: "email", operator: "$EQUAL", value: "test@example.com"}
             ]
    end

    test "handles direct comparisons for overrideable fields" do
      where_params = %{
        "name" => "John",
        "phone" => "1234567890"
      }

      overrideable_fields = ["phone"]
      ignoreable_fields_values = %{}

      result =
        FatBuildableHelper.filter_overrideable_fields(
          where_params,
          overrideable_fields,
          ignoreable_fields_values
        )

      assert result == [
               %{field: "phone", operator: "$EQUAL", value: "1234567890"}
             ]
    end
  end
end
