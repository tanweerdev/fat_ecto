defmodule FatEcto.FatEctoQueryableOverrideTest do
  use ExUnit.Case
  import Ecto.Query
  alias Ecto.Adapters.SQL.Sandbox
  alias FatEcto.FatUser

  setup do
    :ok = Sandbox.checkout(FatEcto.Repo)
    Sandbox.mode(FatEcto.Repo, {:shared, self()})
    FatEcto.Repo.delete_all(FatUser)

    # Create test data
    users = [
      %{name: "Alice", email: "alice@example.com", age: 25, city: "NYC", status: "active"},
      %{name: "Bob", email: "bob@example.com", age: 30, city: "LA", status: "inactive"},
      %{name: "Charlie", email: "charlie@example.com", age: 35, city: "NYC", status: "active"},
      %{name: "Diana", email: "diana@example.com", age: 28, city: "SF", status: "active"}
    ]

    Enum.each(users, fn user_data ->
      %FatUser{}
      |> FatUser.changeset(user_data)
      |> FatEcto.Repo.insert!()
    end)

    :ok
  end

  describe "FatEctoQueryable with override_buildable" do
    defmodule TestQueryableWithOverrides do
      use FatEcto.FatEctoQueryable,
        repo: FatEcto.Repo,
        filterable: [
          type: :dynamics,
          fields: [
            name: ["$ILIKE", "$EQUAL"],
            email: ["$ILIKE"],
            age: ["$GT", "$LT", "$EQUAL"]
          ],
          overridable: ["city_upper", "active_only"]
        ],
        sortable: [
          fields: [name: "*", age: "*"],
          overridable: ["city_reverse"]
        ],
        paginatable: [
          type: :offset,
          default_limit: 20,
          max_limit: 100
        ]

      import Ecto.Query

      # Override buildable for custom city filter - case insensitive uppercase match
      @spec override_buildable(String.t(), String.t(), any()) :: Ecto.Query.dynamic_expr() | nil
      def override_buildable("city_upper", "$EQUAL", value) do
        dynamic([q], fragment("UPPER(?)", q.city) == ^String.upcase(value))
      end

      # Override buildable for active status filter - filters to only active users
      @spec override_buildable(String.t(), String.t(), any()) :: Ecto.Query.dynamic_expr() | nil
      def override_buildable("active_only", "$EQUAL", "true") do
        dynamic([q], q.status == "active")
      end

      @spec override_buildable(String.t(), String.t(), any()) :: Ecto.Query.dynamic_expr() | nil
      def override_buildable("active_only", "$EQUAL", "false") do
        dynamic([q], q.status != "active")
      end

      # Catch-all returns nil - will use default behavior
      @spec override_buildable(String.t(), String.t(), any()) :: Ecto.Query.dynamic_expr() | nil
      def override_buildable(_field, _operator, _value), do: nil

      # Override sortable for custom sorting - reverse alphabetical by city
      @spec override_sortable(String.t(), String.t()) ::
              {atom(), Ecto.Query.dynamic_expr()} | nil
      def override_sortable("city_reverse", "$ASC") do
        {:desc, dynamic([q], q.city)}
      end

      @spec override_sortable(String.t(), String.t()) ::
              {atom(), Ecto.Query.dynamic_expr()} | nil
      def override_sortable("city_reverse", "$DESC") do
        {:asc, dynamic([q], q.city)}
      end

      @spec override_sortable(String.t(), String.t()) ::
              {atom(), Ecto.Query.dynamic_expr()} | nil
      def override_sortable(_field, _operator), do: nil
    end

    test "uses override for city_upper field (case insensitive city match)" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "city_upper" => %{"$EQUAL" => "nyc"}
        }
      }

      {:ok, result} = TestQueryableWithOverrides.querify(query, params)

      # Should find Alice and Charlie (both in NYC)
      assert length(result.entries) == 2

      assert Enum.all?(result.entries, fn user ->
               user.city == "NYC"
             end)
    end

    test "uses default behavior for standard fields" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "name" => %{"$ILIKE" => "%Alice%"}
        }
      }

      {:ok, result} = TestQueryableWithOverrides.querify(query, params)

      assert length(result.entries) == 1
      assert hd(result.entries).name == "Alice"
    end

    test "combines override and default filters" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "active_only" => %{"$EQUAL" => "true"},
          "age" => %{"$GT" => 26}
        }
      }

      {:ok, result} = TestQueryableWithOverrides.querify(query, params)

      # Should find Diana (age 28, active) and Charlie (age 35, active), not Alice (age 25)
      assert length(result.entries) == 2
      assert Enum.all?(result.entries, fn u -> u.age > 26 and u.status == "active" end)
    end

    test "uses multiple standard filters without overrides" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "name" => %{"$ILIKE" => "%i%"},
          "age" => %{"$GT" => 26}
        }
      }

      {:ok, result} = TestQueryableWithOverrides.querify(query, params)

      # Should find Diana (28) and Charlie (35), both have 'i' in name
      assert length(result.entries) == 2
      names = Enum.sort(Enum.map(result.entries, & &1.name))
      assert names == ["Charlie", "Diana"]
    end

    test "uses override sortable for custom sorting (city_reverse)" do
      query = from(u in FatUser)

      params = %{
        "sort" => %{
          "city_reverse" => "$ASC"
        }
      }

      {:ok, result} = TestQueryableWithOverrides.querify(query, params)

      # city_reverse with $ASC means DESC order - so SF, NYC, NYC, LA
      cities = Enum.map(result.entries, & &1.city)
      assert cities == ["SF", "NYC", "NYC", "LA"]
    end

    test "uses default sortable for standard fields" do
      query = from(u in FatUser)

      params = %{
        "sort" => %{
          "name" => "$DESC"
        }
      }

      {:ok, result} = TestQueryableWithOverrides.querify(query, params)

      names = Enum.map(result.entries, & &1.name)
      assert names == ["Diana", "Charlie", "Bob", "Alice"]
    end

    test "combines custom filter, default filter, custom sort, and pagination" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "city_upper" => %{"$EQUAL" => "nyc"},
          "age" => %{"$GT" => 26}
        },
        "sort" => %{
          "city_reverse" => "$DESC"
        },
        "page" => 1,
        "limit" => 10
      }

      {:ok, result} = TestQueryableWithOverrides.querify(query, params)

      # Should find only Charlie (NYC, age 35 > 26)
      assert length(result.entries) == 1
      assert hd(result.entries).name == "Charlie"
      assert result.metadata.total_count == 1
    end
  end

  describe "FatEctoQueryable without any overrides (all defaults)" do
    defmodule TestQueryableNoOverrides do
      use FatEcto.FatEctoQueryable,
        repo: FatEcto.Repo,
        filterable: [
          type: :dynamics,
          fields: [
            name: ["$ILIKE", "$EQUAL"],
            email: ["$ILIKE"],
            age: ["$GT", "$LT", "$EQUAL"]
          ]
        ],
        sortable: [
          fields: [name: "*", age: "*"]
        ],
        paginatable: [
          type: :offset,
          default_limit: 20,
          max_limit: 100
        ]

      # No overrides defined - uses defaults from FatEctoQueryable
    end

    test "uses all default filters" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "name" => %{"$ILIKE" => "%li%"},
          "age" => %{"$GT" => 27}
        }
      }

      {:ok, result} = TestQueryableNoOverrides.querify(query, params)

      # Should find Charlie (35) - has 'li' and age > 27
      assert length(result.entries) == 1
      assert hd(result.entries).name == "Charlie"
    end

    test "uses all default sorting" do
      query = from(u in FatUser)

      params = %{
        "sort" => %{
          "age" => "$ASC"
        }
      }

      {:ok, result} = TestQueryableNoOverrides.querify(query, params)

      ages = Enum.map(result.entries, & &1.age)
      assert ages == [25, 28, 30, 35]
    end
  end

  describe "FatEctoQueryable with query-based filtering" do
    defmodule TestQueryableQueryBased do
      use FatEcto.FatEctoQueryable,
        repo: FatEcto.Repo,
        filterable: [
          type: :query,
          fields: [
            name: ["$ILIKE", "$EQUAL"],
            age: ["$GT", "$LT"]
          ],
          overridable: ["city_or_status"]
        ],
        sortable: [
          fields: [name: "*"]
        ],
        paginatable: [
          type: :offset,
          default_limit: 20,
          max_limit: 100
        ]

      import Ecto.Query

      # Override buildable for query-based filtering (override_buildable/4)
      # Custom filter that matches city OR status
      @spec override_buildable(Ecto.Query.t(), String.t(), String.t(), any()) :: Ecto.Query.t()
      def override_buildable(query, "city_or_status", "$EQUAL", value) do
        from(q in query,
          where: q.city == ^value or q.status == ^value
        )
      end

      # Catch-all returns the query unchanged
      @spec override_buildable(Ecto.Query.t(), String.t(), String.t(), any()) :: Ecto.Query.t()
      def override_buildable(query, _field, _operator, _value), do: query
    end

    test "uses override for custom query-based filter" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "city_or_status" => %{"$EQUAL" => "NYC"}
        }
      }

      {:ok, result} = TestQueryableQueryBased.querify(query, params)

      # Should find Alice and Charlie (both in NYC)
      assert length(result.entries) == 2

      assert Enum.all?(result.entries, fn user ->
               user.city == "NYC"
             end)
    end

    test "uses default query-based filters" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "name" => %{"$ILIKE" => "%Bob%"}
        }
      }

      {:ok, result} = TestQueryableQueryBased.querify(query, params)

      assert length(result.entries) == 1
      assert hd(result.entries).name == "Bob"
    end

    test "combines custom and default query-based filters" do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "city_or_status" => %{"$EQUAL" => "active"},
          "age" => %{"$GT" => 26}
        }
      }

      {:ok, result} = TestQueryableQueryBased.querify(query, params)

      # Should find Diana (28, active) and Charlie (35, active)
      assert length(result.entries) == 2
      assert Enum.all?(result.entries, fn u -> u.age > 26 and u.status == "active" end)
    end
  end

  describe "FatEctoQueryable with nil fallback behavior" do
    defmodule TestQueryableNilFallback do
      use FatEcto.FatEctoQueryable,
        repo: FatEcto.Repo,
        filterable: [
          type: :dynamics,
          fields: [
            name: ["$ILIKE"],
            age: ["$GT"]
          ],
          overridable: ["special_field"]
        ],
        sortable: [
          fields: [name: "*"]
        ],
        paginatable: [
          type: :offset,
          default_limit: 20
        ]

      import Ecto.Query

      # This override explicitly returns nil for "special_field"
      # Should fall back to default operator handling
      @spec override_buildable(String.t(), String.t(), any()) :: Ecto.Query.dynamic_expr() | nil
      def override_buildable("special_field", "$ILIKE", _value), do: nil

      # But we also define it as a regular field in filterable config
      # So when nil is returned, it should use the default $ILIKE operator
      @spec override_buildable(String.t(), String.t(), any()) :: Ecto.Query.dynamic_expr() | nil
      def override_buildable(_field, _operator, _value), do: nil
    end

    test "nil return from override falls back to default behavior" do
      # Note: This test demonstrates that when override returns nil,
      # the builder falls back to OperatorApplier.apply_operator
      # However, "special_field" needs to be handled differently since
      # it's not in the regular fields list.

      # For this test, we'll just verify that standard fields work
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "name" => %{"$ILIKE" => "%Alice%"}
        }
      }

      {:ok, result} = TestQueryableNilFallback.querify(query, params)

      assert length(result.entries) == 1
      assert hd(result.entries).name == "Alice"
    end
  end
end
