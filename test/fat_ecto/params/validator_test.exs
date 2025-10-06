defmodule FatEcto.Params.ValidatorTest do
  use ExUnit.Case, async: true

  alias FatEcto.Params.Validator

  @filterable_fields %{
    "name" => ["$ILIKE", "$EQUAL"],
    "age" => ["$GT", "$LT", "$GTE", "$LTE"],
    "status" => ["$EQUAL", "$IN"]
  }

  @sortable_fields %{
    "name" => ["$ASC", "$DESC"],
    "age" => "*",
    "created_at" => ["$DESC"]
  }

  describe "validate_filters/2 with default behavior (:raise)" do
    test "accepts valid filters" do
      params = %{"name" => %{"$ILIKE" => "%John%"}}
      opts = [filterable_fields: @filterable_fields]

      assert {:ok, ^params} = Validator.validate_filters(params, opts)
    end

    test "rejects unconfigured field" do
      params = %{"email" => %{"$EQUAL" => "test@example.com"}}
      opts = [filterable_fields: @filterable_fields]

      assert {:error, error} = Validator.validate_filters(params, opts)
      assert error =~ "field 'email' is not in the list of filterable fields"
    end

    test "rejects unconfigured operator" do
      params = %{"name" => %{"$GT" => "John"}}
      opts = [filterable_fields: @filterable_fields]

      assert {:error, error} = Validator.validate_filters(params, opts)
      assert error =~ "operator '$GT' is not allowed for field 'name'"
    end
  end

  describe "validate_filters/2 with unconfigured_fields: :ignore" do
    test "ignores unconfigured fields" do
      params = %{
        "name" => %{"$ILIKE" => "%John%"},
        "email" => %{"$EQUAL" => "test@example.com"}
      }

      opts = [filterable_fields: @filterable_fields, unconfigured_fields: :ignore]

      assert {:ok, ^params} = Validator.validate_filters(params, opts)
    end

    test "still validates configured fields" do
      params = %{
        "name" => %{"$GT" => "John"},
        "email" => %{"$EQUAL" => "test@example.com"}
      }

      opts = [filterable_fields: @filterable_fields, unconfigured_fields: :ignore]

      assert {:error, error} = Validator.validate_filters(params, opts)
      assert error =~ "operator '$GT' is not allowed for field 'name'"
    end
  end

  describe "validate_filters/2 with unconfigured_operators: :ignore" do
    test "ignores unconfigured operators" do
      params = %{"name" => %{"$GT" => "John", "$ILIKE" => "%John%"}}
      opts = [filterable_fields: @filterable_fields, unconfigured_operators: :ignore]

      assert {:ok, ^params} = Validator.validate_filters(params, opts)
    end

    test "still validates unconfigured fields by default" do
      params = %{"email" => %{"$EQUAL" => "test@example.com"}}
      opts = [filterable_fields: @filterable_fields, unconfigured_operators: :ignore]

      assert {:error, error} = Validator.validate_filters(params, opts)
      assert error =~ "field 'email' is not in the list of filterable fields"
    end
  end

  describe "validate_filters/2 with both :ignore options" do
    test "ignores both unconfigured fields and operators" do
      params = %{
        "name" => %{"$GT" => "John"},
        "email" => %{"$EQUAL" => "test@example.com"}
      }

      opts = [
        filterable_fields: @filterable_fields,
        unconfigured_fields: :ignore,
        unconfigured_operators: :ignore
      ]

      assert {:ok, ^params} = Validator.validate_filters(params, opts)
    end
  end

  describe "validate_filters/2 with $OR and $AND" do
    test "validates logical operators with default behavior" do
      params = %{
        "$OR" => [
          %{"name" => %{"$ILIKE" => "%John%"}},
          %{"email" => %{"$EQUAL" => "test@example.com"}}
        ]
      }

      opts = [filterable_fields: @filterable_fields]

      assert {:error, error} = Validator.validate_filters(params, opts)
      assert error =~ "field 'email' is not in the list of filterable fields"
    end

    test "validates logical operators with :ignore" do
      params = %{
        "$OR" => [
          %{"name" => %{"$ILIKE" => "%John%"}},
          %{"email" => %{"$EQUAL" => "test@example.com"}}
        ]
      }

      opts = [filterable_fields: @filterable_fields, unconfigured_fields: :ignore]

      assert {:ok, ^params} = Validator.validate_filters(params, opts)
    end
  end

  describe "validate_sort/2 with default behavior (:raise)" do
    test "accepts valid sort params" do
      params = %{"name" => "$ASC"}
      opts = [sortable_fields: @sortable_fields]

      assert {:ok, ^params} = Validator.validate_sort(params, opts)
    end

    test "rejects unconfigured field" do
      params = %{"email" => "$ASC"}
      opts = [sortable_fields: @sortable_fields]

      assert {:error, error} = Validator.validate_sort(params, opts)
      assert error =~ "field 'email' is not in the list of sortable fields"
    end

    test "rejects unconfigured operator" do
      params = %{"name" => "$RANDOM"}
      opts = [sortable_fields: @sortable_fields]

      assert {:error, error} = Validator.validate_sort(params, opts)
      assert error =~ "operator '$RANDOM' is not allowed for field 'name'"
    end

    test "accepts wildcard operators" do
      params = %{"age" => "$ASC"}
      opts = [sortable_fields: @sortable_fields]

      assert {:ok, ^params} = Validator.validate_sort(params, opts)
    end
  end

  describe "validate_sort/2 with unconfigured_fields: :ignore" do
    test "ignores unconfigured fields" do
      params = %{"name" => "$ASC", "email" => "$DESC"}
      opts = [sortable_fields: @sortable_fields, unconfigured_fields: :ignore]

      assert {:ok, ^params} = Validator.validate_sort(params, opts)
    end

    test "still validates configured fields" do
      params = %{"name" => "$RANDOM"}
      opts = [sortable_fields: @sortable_fields, unconfigured_fields: :ignore]

      assert {:error, error} = Validator.validate_sort(params, opts)
      assert error =~ "operator '$RANDOM' is not allowed for field 'name'"
    end
  end

  describe "validate_sort/2 with unconfigured_operators: :ignore" do
    test "ignores unconfigured operators" do
      params = %{"name" => "$RANDOM", "created_at" => "$DESC"}
      opts = [sortable_fields: @sortable_fields, unconfigured_operators: :ignore]

      assert {:ok, ^params} = Validator.validate_sort(params, opts)
    end

    test "still validates unconfigured fields by default" do
      params = %{"email" => "$ASC"}
      opts = [sortable_fields: @sortable_fields, unconfigured_operators: :ignore]

      assert {:error, error} = Validator.validate_sort(params, opts)
      assert error =~ "field 'email' is not in the list of sortable fields"
    end
  end

  describe "validate_sort/2 with both :ignore options" do
    test "ignores both unconfigured fields and operators" do
      params = %{"name" => "$RANDOM", "email" => "$ASC"}

      opts = [
        sortable_fields: @sortable_fields,
        unconfigured_fields: :ignore,
        unconfigured_operators: :ignore
      ]

      assert {:ok, ^params} = Validator.validate_sort(params, opts)
    end
  end

  describe "validate_filters/2 with deeply nested structures" do
    test "validates deeply nested $OR and $AND with :raise" do
      params = %{
        "$OR" => [
          %{
            "$AND" => [
              %{"name" => %{"$ILIKE" => "%John%"}},
              %{"age" => %{"$GT" => 25}}
            ]
          },
          %{
            "$OR" => [
              %{"status" => %{"$EQUAL" => "active"}},
              %{"email" => %{"$EQUAL" => "test@example.com"}}
            ]
          }
        ]
      }

      opts = [filterable_fields: @filterable_fields]

      # Should fail because email is not in filterable fields
      assert {:error, error} = Validator.validate_filters(params, opts)
      assert error =~ "email"
      assert error =~ "not in the list of filterable fields"
    end

    test "validates deeply nested structures with :ignore" do
      params = %{
        "$OR" => [
          %{
            "$AND" => [
              %{"name" => %{"$ILIKE" => "%John%"}},
              %{"email" => %{"$EQUAL" => "test@example.com"}}
            ]
          },
          %{
            "$OR" => [
              %{"status" => %{"$EQUAL" => "active"}},
              %{"unknown_field" => %{"$GT" => 10}}
            ]
          }
        ]
      }

      opts = [filterable_fields: @filterable_fields, unconfigured_fields: :ignore]

      # Should succeed and ignore email and unknown_field
      assert {:ok, ^params} = Validator.validate_filters(params, opts)
    end

    test "validates nested $OR with unconfigured operators" do
      params = %{
        "$OR" => [
          %{"name" => %{"$EQUAL" => "John"}},
          %{"age" => %{"$BETWEEN" => [20, 30]}}
        ]
      }

      opts = [filterable_fields: @filterable_fields]

      # Should fail on unconfigured operators
      assert {:error, error} = Validator.validate_filters(params, opts)
      assert error =~ "$EQUAL" or error =~ "$BETWEEN"
    end

    test "validates nested structures with mixed $AND/$OR and regular fields" do
      params = %{
        "name" => %{"$ILIKE" => "%Smith%"},
        "$OR" => [
          %{"age" => %{"$GT" => 30}},
          %{
            "$AND" => [
              %{"age" => %{"$LT" => 25}},
              %{"status" => %{"$EQUAL" => "active"}}
            ]
          }
        ]
      }

      opts = [filterable_fields: @filterable_fields]

      # Should succeed - all fields and operators are configured
      assert {:ok, ^params} = Validator.validate_filters(params, opts)
    end
  end

  describe "validate/2 with validation options" do
    test "applies validation options to all validations" do
      params = %{
        "filter" => %{
          "name" => %{"$ILIKE" => "%John%"},
          "email" => %{"$EQUAL" => "test@example.com"}
        },
        "sort" => %{"email" => "$ASC"},
        "limit" => 10
      }

      opts = [
        filterable_fields: @filterable_fields,
        sortable_fields: @sortable_fields,
        unconfigured_fields: :ignore,
        max_limit: 100
      ]

      assert {:ok, result} = Validator.validate(params, opts)
      assert result.filter == params["filter"]
      assert result.sort == params["sort"]
      assert result.pagination.limit == 10
    end
  end

  describe "validate_pagination/2" do
    test "accepts valid pagination params" do
      params = %{"limit" => 10, "skip" => 5}
      opts = [max_limit: 100]

      assert {:ok, result} = Validator.validate_pagination(params, opts)
      assert result.limit == 10
      assert result.skip == 5
    end

    test "rejects limit exceeding max" do
      params = %{"limit" => 200}
      opts = [max_limit: 100]

      assert {:error, error} = Validator.validate_pagination(params, opts)
      assert error =~ "exceeds maximum allowed value of 100"
    end
  end
end
