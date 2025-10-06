defmodule FatEcto.FatEctoQueryableValidationTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatUser

  @moduletag :queryable_validation

  # Test queryable with :raise behavior (default)
  defmodule TestQueryableRaise do
    use FatEcto.FatEctoQueryable,
      repo: FatEcto.Repo,
      filterable: [
        type: :dynamics,
        fields: [name: ["$ILIKE"], age: ["$GT"]],
        unconfigured_fields: :raise,
        unconfigured_operators: :raise
      ],
      sortable: [
        fields: [name: ["$ASC"]],
        unconfigured_fields: :raise,
        unconfigured_operators: :raise
      ],
      paginatable: [type: :offset, default_limit: 10, max_limit: 50]
  end

  # Test queryable with :ignore behavior
  defmodule TestQueryableIgnore do
    use FatEcto.FatEctoQueryable,
      repo: FatEcto.Repo,
      filterable: [
        type: :dynamics,
        fields: [name: ["$ILIKE"]],
        unconfigured_fields: :ignore,
        unconfigured_operators: :ignore
      ],
      sortable: [
        fields: [name: ["$ASC"]],
        unconfigured_fields: :ignore,
        unconfigured_operators: :ignore
      ],
      paginatable: [type: :offset, default_limit: 10, max_limit: 50]
  end

  # Test queryable with mixed behavior
  defmodule TestQueryableMixed do
    use FatEcto.FatEctoQueryable,
      repo: FatEcto.Repo,
      filterable: [
        type: :dynamics,
        fields: [name: ["$ILIKE"]],
        unconfigured_fields: :ignore,
        unconfigured_operators: :raise
      ],
      sortable: [
        fields: [name: ["$ASC"]],
        unconfigured_fields: :raise,
        unconfigured_operators: :ignore
      ],
      paginatable: [type: :offset, default_limit: 10, max_limit: 50]
  end

  setup do
    users =
      for i <- 1..5 do
        FatEcto.Repo.insert!(%FatUser{
          name: "User #{i}",
          email: "user#{i}@example.com",
          age: 20 + i
        })
      end

    {:ok, users: users}
  end

  describe "validation with :raise behavior" do
    test "raises error for unconfigured filter field", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{"email" => %{"$EQUAL" => "test@example.com"}}
      }

      assert {:error, error} = TestQueryableRaise.querify(query, params)
      assert error =~ "email"
      assert error =~ "not in the list of filterable fields"
    end

    test "raises error for unconfigured filter operator", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{"name" => %{"$EQUAL" => "User 1"}}
      }

      assert {:error, error} = TestQueryableRaise.querify(query, params)
      assert error =~ "$EQUAL"
      assert error =~ "not allowed for field 'name'"
    end

    test "raises error for unconfigured sort field", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "sort" => %{"age" => "$ASC"}
      }

      assert {:error, error} = TestQueryableRaise.querify(query, params)
      assert error =~ "age"
      assert error =~ "not in the list of sortable fields"
    end

    test "raises error for unconfigured sort operator", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "sort" => %{"name" => "$DESC"}
      }

      assert {:error, error} = TestQueryableRaise.querify(query, params)
      assert error =~ "$DESC"
      assert error =~ "not allowed for field 'name'"
    end

    test "succeeds with configured fields and operators", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{"name" => %{"$ILIKE" => "%User%"}},
        "sort" => %{"name" => "$ASC"}
      }

      assert {:ok, result} = TestQueryableRaise.querify(query, params)
      assert length(result.entries) == 5
    end
  end

  describe "validation with :ignore behavior" do
    test "ignores unconfigured filter fields", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "name" => %{"$ILIKE" => "%User%"},
          "email" => %{"$EQUAL" => "test@example.com"}
        }
      }

      # Should succeed and ignore email filter
      assert {:ok, result} = TestQueryableIgnore.querify(query, params)
      assert length(result.entries) == 5
    end

    test "ignores unconfigured filter operators", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{"name" => %{"$EQUAL" => "User 1", "$ILIKE" => "%User%"}}
      }

      # Should succeed and ignore $EQUAL operator
      assert {:ok, result} = TestQueryableIgnore.querify(query, params)
      assert length(result.entries) == 5
    end

    test "ignores unconfigured sort fields", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "sort" => %{"name" => "$ASC", "age" => "$DESC"}
      }

      # Should succeed and ignore age sort
      assert {:ok, result} = TestQueryableIgnore.querify(query, params)
      assert length(result.entries) == 5
    end

    test "ignores unconfigured sort operators", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "sort" => %{"name" => "$DESC"}
      }

      # Should succeed and ignore $DESC operator
      assert {:ok, result} = TestQueryableIgnore.querify(query, params)
      assert length(result.entries) == 5
    end
  end

  describe "validation with mixed behavior" do
    test "ignores unconfigured filter fields but raises on operators", %{users: _users} do
      query = from(u in FatUser)

      # Unconfigured field should be ignored
      params1 = %{
        "filter" => %{"email" => %{"$EQUAL" => "test@example.com"}}
      }

      assert {:ok, _result} = TestQueryableMixed.querify(query, params1)

      # Unconfigured operator should raise
      params2 = %{
        "filter" => %{"name" => %{"$EQUAL" => "User 1"}}
      }

      assert {:error, error} = TestQueryableMixed.querify(query, params2)
      assert error =~ "$EQUAL"
    end

    test "raises on unconfigured sort fields but ignores operators", %{users: _users} do
      query = from(u in FatUser)

      # Unconfigured operator should be ignored
      params1 = %{
        "sort" => %{"name" => "$DESC"}
      }

      assert {:ok, _result} = TestQueryableMixed.querify(query, params1)

      # Unconfigured field should raise
      params2 = %{
        "sort" => %{"age" => "$ASC"}
      }

      assert {:error, error} = TestQueryableMixed.querify(query, params2)
      assert error =~ "age"
    end
  end

  describe "deeply nested $OR/$AND validation" do
    test "validates deeply nested structures with :raise", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "$OR" => [
            %{
              "$AND" => [
                %{"name" => %{"$ILIKE" => "%User%"}},
                %{"email" => %{"$EQUAL" => "test@example.com"}}
              ]
            },
            %{"age" => %{"$GT" => 30}}
          ]
        }
      }

      # Should fail because email is not configured
      assert {:error, error} = TestQueryableRaise.querify(query, params)
      assert error =~ "email"
    end

    test "validates deeply nested structures with :ignore", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "name" => %{"$ILIKE" => "%User%"},
          "$OR" => [
            %{
              "$AND" => [
                %{"age" => %{"$GT" => 20}},
                %{"email" => %{"$EQUAL" => "test@example.com"}}
              ]
            },
            %{"unknown_field" => %{"$LT" => 100}}
          ]
        }
      }

      # Should succeed - ignores email and unknown_field
      assert {:ok, result} = TestQueryableIgnore.querify(query, params)
      assert length(result.entries) == 5
    end

    test "validates complex nested structure with 3+ levels", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "$OR" => [
            %{
              "$AND" => [
                %{"name" => %{"$ILIKE" => "%User%"}},
                %{
                  "$OR" => [
                    %{"age" => %{"$GT" => 25}},
                    %{"age" => %{"$GT" => 19}}
                  ]
                }
              ]
            },
            %{"name" => %{"$ILIKE" => "%Admin%"}}
          ]
        }
      }

      # Should succeed - all fields and operators are configured
      assert {:ok, result} = TestQueryableRaise.querify(query, params)
      # Users with (age > 25 or age > 19) and name like %User%, or name like %Admin%
      assert is_list(result.entries)
    end
  end
end
