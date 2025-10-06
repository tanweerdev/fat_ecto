defmodule FatEcto.Query.Dynamics.BuildableDocsTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatUser
  alias FatEcto.Query.Dynamics.Buildable

  @moduletag :buildable_docs

  describe "Quick Start Examples" do
    test "direct usage example" do
      opts = [
        filterable: [
          id: ["$EQUAL", "$IN"],
          name: ["$ILIKE", "$EQUAL"],
          age: ["$GT", "$GTE", "$LT", "$LTE"],
          status: ["$EQUAL", "$IN", "$NOT_EQUAL"]
        ]
      ]

      params = %{
        "name" => %{"$ILIKE" => "%John%"},
        "age" => %{"$GT" => 25}
      }

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)

      assert dynamics != nil
      # Verify it can be used in a query
      query = from(u in FatUser, where: ^dynamics)
      assert %Ecto.Query{} = query
    end

    test "macro usage example" do
      defmodule TestUserFilter do
        use FatEcto.Query.Dynamics.Buildable,
          filterable: [name: ["$ILIKE"], age: ["$GT", "$LT"]]

        @impl true
        def override_buildable(_field, _operator, _value), do: nil
      end

      params = %{"name" => %{"$ILIKE" => "%test%"}}
      dynamics = TestUserFilter.build(params)

      assert dynamics != nil
    end
  end

  describe "Basic Examples" do
    test "example 1: simple equality" do
      params = %{"email" => %{"$EQUAL" => "user@example.com"}}
      opts = [filterable: [email: ["$EQUAL"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "example 2: pattern matching" do
      params = %{"name" => %{"$ILIKE" => "%john%"}}
      opts = [filterable: [name: ["$ILIKE"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "example 3: range query" do
      params = %{
        "age" => %{"$GTE" => 18, "$LTE" => 65}
      }

      opts = [filterable: [age: ["$GTE", "$LTE"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "example 4: IN operator" do
      params = %{
        "status" => %{"$IN" => ["active", "pending", "approved"]}
      }

      opts = [filterable: [status: ["$IN"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "example 5: NULL checks" do
      params = %{
        "deleted_at" => %{"$NULL" => true}
      }

      opts = [filterable: [deleted_at: ["$NULL"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end
  end

  describe "Logical Operators Examples" do
    test "simple OR" do
      params = %{
        "$OR" => [
          %{"status" => %{"$EQUAL" => "active"}},
          %{"status" => %{"$EQUAL" => "pending"}}
        ]
      }

      opts = [filterable: [status: ["$EQUAL"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "simple AND" do
      params = %{
        "$AND" => [
          %{"age" => %{"$GT" => 18}},
          %{"age" => %{"$LT" => 65}}
        ]
      }

      opts = [filterable: [age: ["$GT", "$LT"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "combined regular fields with OR" do
      params = %{
        "name" => %{"$ILIKE" => "%Smith%"},
        "$OR" => [
          %{"age" => %{"$GT" => 50}},
          %{"status" => %{"$EQUAL" => "premium"}}
        ]
      }

      opts = [filterable: [name: ["$ILIKE"], age: ["$GT"], status: ["$EQUAL"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end
  end

  describe "Complex Nested Queries Examples" do
    test "nested OR and AND (2 levels)" do
      params = %{
        "$OR" => [
          %{
            "$AND" => [
              %{"name" => %{"$ILIKE" => "%John%"}},
              %{"age" => %{"$GT" => 25}}
            ]
          },
          %{
            "$AND" => [
              %{"name" => %{"$ILIKE" => "%Jane%"}},
              %{"age" => %{"$LT" => 30}}
            ]
          }
        ]
      }

      opts = [filterable: [name: ["$ILIKE"], age: ["$GT", "$LT"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "deep nesting (3+ levels)" do
      params = %{
        "$OR" => [
          %{
            "$AND" => [
              %{"department" => %{"$EQUAL" => "Engineering"}},
              %{
                "$OR" => [
                  %{"role" => %{"$EQUAL" => "Senior"}},
                  %{"experience" => %{"$GT" => 5}}
                ]
              }
            ]
          },
          %{"is_admin" => %{"$EQUAL" => true}}
        ]
      }

      opts = [
        filterable: [
          department: ["$EQUAL"],
          role: ["$EQUAL"],
          experience: ["$GT"],
          is_admin: ["$EQUAL"]
        ]
      ]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "multiple conditions at root level" do
      params = %{
        "status" => %{"$EQUAL" => "active"},
        "verified" => %{"$EQUAL" => true},
        "$OR" => [
          %{"subscription" => %{"$EQUAL" => "premium"}},
          %{"credits" => %{"$GT" => 100}}
        ]
      }

      opts = [
        filterable: [
          status: ["$EQUAL"],
          verified: ["$EQUAL"],
          subscription: ["$EQUAL"],
          credits: ["$GT"]
        ]
      ]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end
  end

  describe "Custom Overrides Examples" do
    test "example 1: case-insensitive search" do
      override_fn = fn field, operator, value ->
        case {field, operator} do
          {"email", "$EQUAL"} ->
            # Compare emails case-insensitively
            dynamic([q], fragment("LOWER(?)", q.email) == ^String.downcase(value))

          _ ->
            nil
        end
      end

      params = %{"email" => %{"$EQUAL" => "User@Example.COM"}}
      opts = [filterable: [email: ["$EQUAL"]], overrideable: ["email"]]

      dynamics = Buildable.build(params, opts, override_fn)
      assert dynamics != nil
    end

    test "example 2: full-text search" do
      override_fn = fn field, operator, value ->
        case {field, operator} do
          {"content", "$SEARCH"} ->
            # PostgreSQL full-text search
            dynamic(
              [q],
              fragment(
                "to_tsvector('english', ?) @@ plainto_tsquery('english', ?)",
                q.content,
                ^value
              )
            )

          _ ->
            nil
        end
      end

      params = %{"content" => %{"$SEARCH" => "elixir phoenix"}}
      opts = [overrideable: ["content"]]

      dynamics = Buildable.build(params, opts, override_fn)
      assert dynamics != nil
    end

    test "example 3: geographic distance" do
      override_fn = fn field, operator, value ->
        case {field, operator} do
          {"location", "$NEAR"} ->
            %{"lat" => lat, "lng" => lng, "distance" => distance} = value

            dynamic(
              [q],
              fragment(
                "earth_distance(ll_to_earth(?, ?), ll_to_earth(?, ?)) < ?",
                q.latitude,
                q.longitude,
                ^lat,
                ^lng,
                ^distance
              )
            )

          _ ->
            nil
        end
      end

      params = %{
        "location" => %{
          "$NEAR" => %{"lat" => 40.7128, "lng" => -74.0060, "distance" => 5000}
        }
      }

      opts = [overrideable: ["location"]]
      dynamics = Buildable.build(params, opts, override_fn)
      assert dynamics != nil
    end

    test "example 4: date range shortcuts" do
      override_fn = fn field, operator, value ->
        case {field, operator} do
          {"created_at", "$LAST_DAYS"} ->
            days = String.to_integer(value)
            date = DateTime.add(DateTime.utc_now(), -days * 86400, :second)
            dynamic([q], q.created_at >= ^date)

          _ ->
            nil
        end
      end

      params = %{"created_at" => %{"$LAST_DAYS" => "7"}}
      opts = [overrideable: ["created_at"]]

      dynamics = Buildable.build(params, opts, override_fn)
      assert dynamics != nil
    end
  end

  describe "Ignoreable Fields Examples" do
    test "ignore empty strings and wildcards" do
      params = %{
        "name" => %{"$ILIKE" => "%%"},
        # Wildcard only - should ignore
        "email" => %{"$EQUAL" => ""},
        # Empty - should ignore
        "age" => %{"$GT" => nil},
        # Nil - should ignore
        "status" => %{"$EQUAL" => "active"}
        # Valid - should keep
      }

      opts = [
        filterable: [name: ["$ILIKE"], email: ["$EQUAL"], age: ["$GT"], status: ["$EQUAL"]],
        ignoreable: [
          name: ["%%", ""],
          email: ["", nil],
          age: [nil]
        ]
      ]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Only builds dynamic for status field
      assert dynamics != nil
    end
  end

  describe "Real-World Use Cases Examples" do
    test "use case 1: REST API product search" do
      params = %{
        "name" => %{"$ILIKE" => "%laptop%"},
        "category" => %{"$IN" => ["electronics", "computers"]},
        "price" => %{"$GTE" => 500, "$LTE" => 2000}
      }

      opts = [
        filterable: [
          name: ["$ILIKE"],
          category: ["$IN"],
          price: ["$GT", "$GTE", "$LT", "$LTE"],
          in_stock: ["$EQUAL"],
          rating: ["$GTE"]
        ],
        ignoreable: [
          name: ["%%", ""],
          price: [nil]
        ]
      ]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "use case 2: user dashboard filters" do
      params = %{
        "$OR" => [
          %{"role" => %{"$EQUAL" => "admin"}},
          %{
            "$AND" => [
              %{"department" => %{"$EQUAL" => "Sales"}},
              %{"status" => %{"$EQUAL" => "active"}},
              %{"performance_score" => %{"$GTE" => 80}}
            ]
          }
        ]
      }

      opts = [
        filterable: [
          role: ["$EQUAL"],
          department: ["$EQUAL"],
          status: ["$EQUAL"],
          performance_score: ["$GTE"]
        ]
      ]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      assert dynamics != nil
    end

    test "use case 3: event logs with time ranges" do
      override_fn = fn field, operator, value ->
        case {field, operator} do
          {"timestamp", "$BETWEEN"} ->
            [start_time, end_time] = value
            dynamic([q], q.timestamp >= ^start_time and q.timestamp <= ^end_time)

          _ ->
            nil
        end
      end

      params = %{
        "level" => %{"$IN" => ["error", "critical"]},
        "timestamp" => %{
          "$BETWEEN" => [~U[2024-01-01 00:00:00Z], ~U[2024-01-31 23:59:59Z]]
        },
        "service" => %{"$EQUAL" => "api"}
      }

      opts = [
        filterable: [level: ["$IN"], service: ["$EQUAL"]],
        overrideable: ["timestamp"]
      ]

      dynamics = Buildable.build(params, opts, override_fn)
      assert dynamics != nil
    end
  end

  describe "Integration Tests - Actually Query Database" do
    setup do
      # Create test users
      users =
        for i <- 1..10 do
          FatEcto.Repo.insert!(%FatUser{
            name: "User #{i}",
            email: "user#{i}@example.com",
            age: 20 + i
          })
        end

      {:ok, users: users}
    end

    test "basic example works end-to-end", %{users: _users} do
      params = %{"age" => %{"$GT" => 25}}
      opts = [filterable: [age: ["$GT"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)

      query = from(u in FatUser, where: ^dynamics)
      results = FatEcto.Repo.all(query)

      # Should return users with age > 25 (users 6-10)
      assert length(results) == 5
      assert Enum.all?(results, fn u -> u.age > 25 end)
    end

    test "range query works end-to-end", %{users: _users} do
      params = %{
        "age" => %{"$GTE" => 23, "$LTE" => 27}
      }

      opts = [filterable: [age: ["$GTE", "$LTE"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)

      query = from(u in FatUser, where: ^dynamics)
      results = FatEcto.Repo.all(query)

      # Should return users with age 23-27 (users 3-7)
      assert length(results) == 5
      assert Enum.all?(results, fn u -> u.age >= 23 and u.age <= 27 end)
    end

    test "pattern matching works end-to-end", %{users: _users} do
      params = %{"name" => %{"$ILIKE" => "%user 5%"}}
      opts = [filterable: [name: ["$ILIKE"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)

      query = from(u in FatUser, where: ^dynamics)
      results = FatEcto.Repo.all(query)

      assert length(results) == 1
      assert hd(results).name == "User 5"
    end

    test "OR condition works end-to-end", %{users: _users} do
      params = %{
        "$OR" => [
          %{"age" => %{"$EQUAL" => 21}},
          %{"age" => %{"$EQUAL" => 25}}
        ]
      }

      opts = [filterable: [age: ["$EQUAL"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)

      query = from(u in FatUser, where: ^dynamics)
      results = FatEcto.Repo.all(query)

      assert length(results) == 2
      ages = Enum.map(results, & &1.age)
      assert 21 in ages
      assert 25 in ages
    end

    test "nested conditions work end-to-end", %{users: _users} do
      params = %{
        "$OR" => [
          %{
            "$AND" => [
              %{"name" => %{"$ILIKE" => "%User%"}},
              %{"age" => %{"$GT" => 27}}
            ]
          },
          %{"age" => %{"$EQUAL" => 21}}
        ]
      }

      opts = [filterable: [name: ["$ILIKE"], age: ["$GT", "$EQUAL"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)

      query = from(u in FatUser, where: ^dynamics)
      results = FatEcto.Repo.all(query)

      # Should return: (name like '%User%' AND age > 27) OR age == 21
      # Users 8, 9, 10 (age 28, 29, 30) + User 1 (age 21) = 4 users
      assert length(results) == 4
    end

    test "ignoreable fields work end-to-end", %{users: _users} do
      params = %{
        "name" => %{"$ILIKE" => "%%"},
        # Should be ignored
        "age" => %{"$GT" => 25}
        # Should be applied
      }

      opts = [
        filterable: [name: ["$ILIKE"], age: ["$GT"]],
        ignoreable: [name: ["%%"]]
      ]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)

      query = from(u in FatUser, where: ^dynamics)
      results = FatEcto.Repo.all(query)

      # Should only apply age filter
      assert length(results) == 5
      assert Enum.all?(results, fn u -> u.age > 25 end)
    end

    test "custom override works end-to-end", %{users: _users} do
      override_fn = fn field, operator, value ->
        case {field, operator} do
          {"email", "$EQUAL"} ->
            # Case-insensitive email comparison
            dynamic([q], fragment("LOWER(?)", q.email) == ^String.downcase(value))

          _ ->
            nil
        end
      end

      params = %{"email" => %{"$EQUAL" => "USER3@EXAMPLE.COM"}}
      opts = [filterable: [email: ["$EQUAL"]], overrideable: ["email"]]

      dynamics = Buildable.build(params, opts, override_fn)

      query = from(u in FatUser, where: ^dynamics)
      results = FatEcto.Repo.all(query)

      assert length(results) == 1
      assert hd(results).email == "user3@example.com"
    end
  end
end
