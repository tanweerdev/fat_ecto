defmodule FatEcto.Query.Dynamics.Buildable do
  @moduledoc """
  Comprehensive query dynamics builder with support for complex filtering, logical operators, and custom overrides.

  This module provides a flexible and powerful way to build Ecto query dynamics from user input,
  commonly used in REST APIs, GraphQL resolvers, or any scenario requiring dynamic filtering.

  ## Table of Contents

  - [Quick Start](#module-quick-start)
  - [Supported Operators](#module-supported-operators)
  - [Basic Examples](#module-basic-examples)
  - [Logical Operators ($OR, $AND)](#module-logical-operators-or-and)
  - [Complex Nested Queries](#module-complex-nested-queries)
  - [Custom Overrides](#module-custom-overrides)
  - [Ignoreable Fields](#module-ignoreable-fields)
  - [Real-World Use Cases](#module-real-world-use-cases)
  - [API Reference](#module-api-reference)

  ## Quick Start

  ### Direct Usage (Recommended)

      import Ecto.Query
      alias FatEcto.Query.Dynamics.Buildable

      # Configure which fields can be filtered and with which operators
      opts = [
        filterable: [
          id: ["$EQUAL", "$IN"],
          name: ["$ILIKE", "$EQUAL"],
          age: ["$GT", "$GTE", "$LT", "$LTE"],
          status: ["$EQUAL", "$IN", "$NOT_EQUAL"]
        ]
      ]

      # Build dynamics from user params
      params = %{
        "name" => %{"$ILIKE" => "%John%"},
        "age" => %{"$GT" => 25}
      }

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)

      # Use in your query
      query = from(u in User, where: ^dynamics)
      Repo.all(query)

  ### Macro Usage (Legacy)

      defmodule MyApp.UserFilter do
        use FatEcto.Query.Dynamics.Buildable,
          filterable: [name: ["$ILIKE"], age: ["$GT", "$LT"]]

        def override_buildable(_field, _operator, _value), do: nil
      end

      dynamics = MyApp.UserFilter.build(params)

  ## Supported Operators

  ### Comparison Operators

  - `$EQUAL` - Exact match (`WHERE field = value`)
  - `$NOT_EQUAL` - Not equal (`WHERE field != value`)
  - `$GT` - Greater than (`WHERE field > value`)
  - `$GTE` - Greater than or equal (`WHERE field >= value`)
  - `$LT` - Less than (`WHERE field < value`)
  - `$LTE` - Less than or equal (`WHERE field <= value`)

  ### Pattern Matching

  - `$LIKE` - Case-sensitive pattern match (`WHERE field LIKE value`)
  - `$ILIKE` - Case-insensitive pattern match (`WHERE field ILIKE value`)
  - `$NOT_LIKE` - Negated case-sensitive pattern (`WHERE field NOT LIKE value`)
  - `$NOT_ILIKE` - Negated case-insensitive pattern (`WHERE field NOT ILIKE value`)

  ### Set Operations

  - `$IN` - Value in list (`WHERE field IN (value1, value2, ...)`)
  - `$NOT_IN` - Value not in list (`WHERE field NOT IN (value1, value2, ...)`)

  ### Special Operators

  - `$NULL` - Field is null (`WHERE field IS NULL`)
  - `$NOT_NULL` - Field is not null (`WHERE field IS NOT NULL`)

  ### Logical Operators

  - `$OR` - Logical OR (combines conditions with OR)
  - `$AND` - Logical AND (combines conditions with AND)

  ## Basic Examples

  ### Example 1: Simple Equality

      params = %{"email" => %{"$EQUAL" => "user@example.com"}}
      opts = [filterable: [email: ["$EQUAL"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Generates: dynamic([q], q.email == ^"user@example.com")

  ### Example 2: Pattern Matching

      params = %{"name" => %{"$ILIKE" => "%john%"}}
      opts = [filterable: [name: ["$ILIKE"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Generates: dynamic([q], ilike(q.name, ^"%john%"))

  ### Example 3: Range Query

      params = %{
        "age" => %{"$GTE" => 18, "$LTE" => 65}
      }
      opts = [filterable: [age: ["$GTE", "$LTE"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Generates: dynamic([q], q.age >= ^18 and q.age <= ^65)

  ### Example 4: IN Operator

      params = %{
        "status" => %{"$IN" => ["active", "pending", "approved"]}
      }
      opts = [filterable: [status: ["$IN"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Generates: dynamic([q], q.status in ^["active", "pending", "approved"])

  ### Example 5: NULL Checks

      params = %{
        "deleted_at" => %{"$NULL" => true}
      }
      opts = [filterable: [deleted_at: ["$NULL"]]]

      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Generates: dynamic([q], is_nil(q.deleted_at))

  ## Logical Operators ($OR, $AND)

  ### Simple OR

      params = %{
        "$OR" => [
          %{"status" => %{"$EQUAL" => "active"}},
          %{"status" => %{"$EQUAL" => "pending"}}
        ]
      }

      opts = [filterable: [status: ["$EQUAL"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Generates: dynamic([q], q.status == ^"active" or q.status == ^"pending")

  ### Simple AND

      params = %{
        "$AND" => [
          %{"age" => %{"$GT" => 18}},
          %{"age" => %{"$LT" => 65}}
        ]
      }

      opts = [filterable: [age: ["$GT", "$LT"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Generates: dynamic([q], q.age > ^18 and q.age < ^65)

  ### Combined Regular Fields with OR

      params = %{
        "name" => %{"$ILIKE" => "%Smith%"},
        "$OR" => [
          %{"age" => %{"$GT" => 50}},
          %{"status" => %{"$EQUAL" => "premium"}}
        ]
      }

      opts = [filterable: [name: ["$ILIKE"], age: ["$GT"], status: ["$EQUAL"]]]
      dynamics = Buildable.build(params, opts, fn _, _, _ -> nil end)
      # Generates: dynamic([q],
      #   q.name ilike ^"%Smith%" and
      #   (q.age > ^50 or q.status == ^"premium")
      # )

  ## Complex Nested Queries

  ### Nested OR and AND (2 levels)

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
      # Generates: (name ILIKE '%John%' AND age > 25) OR (name ILIKE '%Jane%' AND age < 30)

  ### Deep Nesting (3+ levels)

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
      # Generates complex nested conditions

  ### Multiple Conditions at Root Level

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
      # All root conditions are combined with AND

  ## Custom Overrides

  Custom overrides allow you to implement special filtering logic for specific fields.

  ### Example 1: Case-Insensitive Search

      override_fn = fn field, operator, value ->
        import Ecto.Query

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

  ### Example 2: Full-Text Search

      override_fn = fn field, operator, value ->
        import Ecto.Query

        case {field, operator} do
          {"content", "$SEARCH"} ->
            # PostgreSQL full-text search
            dynamic([q],
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

  ### Example 3: Geographic Distance

      override_fn = fn field, operator, value ->
        import Ecto.Query

        case {field, operator} do
          {"location", "$NEAR"} ->
            %{"lat" => lat, "lng" => lng, "distance" => distance} = value

            dynamic([q],
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

  ### Example 4: Date Range Shortcuts

      override_fn = fn field, operator, value ->
        import Ecto.Query

        case {field, operator} do
          {"created_at", "$LAST_DAYS"} ->
            days = String.to_integer(value)
            date = DateTime.add(DateTime.utc_now(), -days * 86400, :second)
            dynamic([q], q.created_at >= ^date)

          {"created_at", "$THIS_MONTH"} ->
            start_of_month = Timex.beginning_of_month(DateTime.utc_now())
            dynamic([q], q.created_at >= ^start_of_month)

          _ ->
            nil
        end
      end

      params = %{"created_at" => %{"$LAST_DAYS" => "7"}}
      opts = [overrideable: ["created_at"]]

      dynamics = Buildable.build(params, opts, override_fn)

  ## Ignoreable Fields

  Ignoreable fields allow you to filter out empty or meaningless values before building dynamics.

  ### Example: Ignore Empty Strings and Wildcards

      params = %{
        "name" => %{"$ILIKE" => "%%"},      # Wildcard only - should ignore
        "email" => %{"$EQUAL" => ""},       # Empty - should ignore
        "age" => %{"$GT" => nil},           # Nil - should ignore
        "status" => %{"$EQUAL" => "active"} # Valid - should keep
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

  ## Real-World Use Cases

  ### Use Case 1: REST API Product Search

      defmodule MyApp.ProductFilter do
        import Ecto.Query
        alias FatEcto.Query.Dynamics.Buildable

        def filter_products(params) do
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

          from(p in Product, where: ^dynamics)
          |> Repo.all()
        end
      end

      # Client request:
      # GET /api/products?name=laptop&category[]=electronics&category[]=computers&price_min=500&price_max=2000

      params = %{
        "name" => %{"$ILIKE" => "%laptop%"},
        "category" => %{"$IN" => ["electronics", "computers"]},
        "price" => %{"$GTE" => 500, "$LTE" => 2000}
      }

      MyApp.ProductFilter.filter_products(params)

  ### Use Case 2: User Dashboard Filters

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
      # Returns: Admins OR (Sales team members who are active with score >= 80)

  ### Use Case 3: Event Logs with Time Ranges

      override_fn = fn field, operator, value ->
        import Ecto.Query

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

  ## API Reference

  See function documentation below for detailed parameter descriptions and return types.
  """

  alias FatEcto.Query.Dynamics.Builder
  alias FatEcto.Query.Helper

  # ============================================================================
  # PUBLIC API - Pure Functions
  # ============================================================================

  @doc """
  Builds dynamics after filtering fields based on the provided parameters.

  ## Parameters
  - `where_params` - Map of fields and their filtering operators
  - `opts` - Configuration options:
    - `:filterable` - List of filterable fields and operators (e.g., `[id: ["$EQUAL"], name: ["$ILIKE"]]`)
    - `:overrideable` - List of overrideable field names (e.g., `["custom_field"]`)
    - `:ignoreable` - List of ignoreable field values (e.g., `[name: ["%%", "", nil]]`)
    - `:unconfigured_fields` - How to handle unconfigured fields: `:raise` (default), `:warn`, `:ignore`
    - `:unconfigured_operators` - How to handle unconfigured operators: `:raise` (default), `:warn`, `:ignore`
  - `override_callback` - Function to handle overrideable fields `(field, operator, value) -> dynamic | nil`
  - `after_callback` - Optional function to process final dynamics `(dynamics) -> dynamics`

  ## Returns
  - Ecto.Query.dynamic_expr() or nil
  """
  @spec build(
          map() | nil,
          keyword(),
          (String.t() | atom(), String.t(), any() -> Ecto.Query.dynamic_expr() | nil),
          (Ecto.Query.dynamic_expr() | nil -> any())
        ) :: Ecto.Query.dynamic_expr() | nil
  def build(where_params, opts, override_callback, after_callback \\ &default_after_callback/1)

  def build(where_params, opts, override_callback, after_callback) when is_map(where_params) do
    # Validate options
    validate_options!(opts)

    # Build configuration
    config = build_config(opts)

    # Remove ignoreable fields from the params
    where_params_ignoreables_removed =
      Helper.remove_ignoreable_fields(where_params, config.ignoreable_fields_values)

    # Only keep filterable fields in params
    filterable_params =
      Helper.filter_filterable_fields(
        where_params_ignoreables_removed,
        config.filterable_fields,
        config.overrideable_fields
      )

    # Build dynamics with the override callback
    dynamics =
      Builder.build(
        filterable_params,
        override_callback,
        config.overrideable_fields
      )

    # Apply after_buildable callback
    after_callback.(dynamics)
  end

  def build(_where_params, _opts, _override_callback, after_callback) do
    after_callback.(nil)
  end

  # ============================================================================
  # BACKWARD COMPATIBLE MACRO
  # ============================================================================

  @doc """
  Callback for handling custom filtering logic for overrideable fields.

  This function acts as a fallback for overrideable fields. The default behavior is to return nil,
  but it can be overridden by the using module.
  """
  @callback override_buildable(
              field :: String.t() | atom(),
              operator :: String.t(),
              value :: any()
            ) :: Ecto.Query.dynamic_expr()

  @doc """
  Callback for performing custom processing on the final dynamics.

  This function is called at the end of the `build/2` function. The default behavior is to return the dynamics,
  but it can be overridden by the using module.
  """
  @callback after_buildable(dynamics :: Ecto.Query.dynamic_expr() | nil) :: any()

  defmacro __using__(options \\ []) do
    # Validate options at compile time
    validate_options!(options)

    quote location: :keep do
      @behaviour FatEcto.Query.Dynamics.Buildable
      @options unquote(options)
      @filterable @options[:filterable] || []
      @overrideable_fields @options[:overrideable] || []
      @ignoreable @options[:ignoreable] || []

      @buildable_opts [
        filterable: @filterable,
        overrideable: @overrideable_fields,
        ignoreable: @ignoreable
      ]

      @doc """
      Builds dynamics after filtering fields based on the provided parameters.
      Delegates to FatEcto.Query.Dynamics.Buildable.build/4

      ### Parameters
        - `where_params`: A map of fields and their filtering operators (e.g., `%{"field" => %{"$EQUAL" => "value"}}`).
        - `build_options`: Additional options for dynamics building (passed to `Builder`).

      ### Returns
        - The dynamics with filtering applied.
      """
      @spec build(map() | nil, keyword()) :: Ecto.Query.dynamic_expr() | nil
      def build(where_params \\ nil, build_options \\ [])

      def build(where_params, _build_options) do
        unquote(__MODULE__).build(
          where_params,
          @buildable_opts,
          &override_buildable/3,
          &after_buildable/1
        )
      end

      # Only define default override_buildable/3 if no overrideable fields are configured
      if @overrideable_fields == [] do
        @doc """
        Default implementation of `override_buildable/3` when no overrideable fields are configured.
        """
        @impl true
        def override_buildable(_field, _operator, _value), do: nil

        defoverridable override_buildable: 3
      end

      @doc """
      Default implementation of after_buildable/1.

      This function can be overridden by the using module to perform custom processing on the final dynamics.
      """
      @impl true
      def after_buildable(dynamics), do: dynamics

      defoverridable after_buildable: 1
    end
  end

  # ============================================================================
  # PRIVATE HELPER FUNCTIONS
  # ============================================================================

  defp validate_options!(options) do
    filterable = Keyword.get(options, :filterable, [])
    overrideable = Keyword.get(options, :overrideable, [])

    # Ensure at least one of `filterable` or `overrideable` fields option is provided
    if filterable == [] and overrideable == [] do
      raise ArgumentError, """
      You must provide at least one of `filterable` or `overrideable` option.
      Example:
        use FatEcto.Query.Dynamics.Buildable,
          filterable: [id: ["$EQUAL", "$NOT_EQUAL"]],
          overrideable: [:name, :phone]
      """
    end

    # Validate format of filterable and overrideable
    unless (is_list(filterable) || is_nil(filterable)) and
             (is_list(overrideable) || is_nil(overrideable)) do
      raise ArgumentError, """
      Format for `filterable` or `overrideable` fields should be in expected format.
      Example:
        use FatEcto.Query.Dynamics.Buildable,
          filterable: [id: ["$EQUAL", "$NOT_EQUAL"]],
          overrideable: [:name, :phone]
      """
    end

    :ok
  end

  defp build_config(opts) do
    filterable = Keyword.get(opts, :filterable, [])
    overrideable_fields = Keyword.get(opts, :overrideable, [])
    ignoreable = Keyword.get(opts, :ignoreable, [])

    %{
      filterable_fields: FatEcto.SharedHelper.filterable_opt_to_map(filterable),
      overrideable_fields: overrideable_fields,
      ignoreable_fields_values: FatEcto.SharedHelper.keyword_list_to_map(ignoreable)
    }
  end

  defp default_after_callback(dynamics), do: dynamics
end
