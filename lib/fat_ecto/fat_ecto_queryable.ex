defmodule FatEcto.FatEctoQueryable do
  @moduledoc """
  Unified query builder that orchestrates filtering, sorting, and pagination.

  This module is a thin composition layer that delegates to existing FatEcto modules:
  - `FatEcto.Query.Buildable` or `FatEcto.Query.Dynamics.Buildable` for filtering
  - `FatEcto.Sort.Sortable` for sorting
  - `FatEcto.Pagination.OffsetPaginator` or `CursorPaginator` for pagination

  ## Basic Setup

      defmodule MyApp.UserQueryable do
        use FatEcto.FatEctoQueryable,
          repo: MyApp.Repo,
          filterable: [
            type: :dynamics,
            fields: [
              name: ["$ILIKE", "$EQUAL"],
              age: ["$GT", "$GTE", "$LT", "$LTE"],
              email: ["$EQUAL"]
            ],
            # Optional validation options
            unconfigured_fields: :raise,     # :raise (default), :warn, :ignore
            unconfigured_operators: :raise   # :raise (default), :warn, :ignore
          ],
          sortable: [
            fields: [name: "*", age: "*", created_at: "*"],
            # Optional validation options
            unconfigured_fields: :raise,     # :raise (default), :warn, :ignore
            unconfigured_operators: :raise   # :raise (default), :warn, :ignore
          ],
          paginatable: [
            type: :offset,
            default_limit: 20,
            max_limit: 100
          ]
      end

  ## Example 1: Simple Filtering

      query = from(u in User)
      params = %{"filter" => %{"name" => %{"$ILIKE" => "%John%"}}}

      {:ok, result} = MyApp.UserQueryable.querify(query, params)
      # Returns users with "John" in their name

  ## Example 2: Multiple Filters

      params = %{
        "filter" => %{
          "age" => %{"$GT" => 25, "$LT" => 50},
          "name" => %{"$ILIKE" => "%Smith%"}
        }
      }

      {:ok, result} = MyApp.UserQueryable.querify(query, params)
      # Returns users aged 26-49 with "Smith" in their name

  ## Example 3: Filtering with Sorting

      params = %{
        "filter" => %{"age" => %{"$GT" => 18}},
        "sort" => %{"name" => "$ASC", "age" => "$DESC"}
      }

      {:ok, result} = MyApp.UserQueryable.querify(query, params)
      # Returns adults sorted by name (A-Z), then age (descending)

  ## Example 4: Pagination Styles

  ### Page-based pagination:

      params = %{
        "filter" => %{"age" => %{"$GT" => 18}},
        "page" => 2,
        "limit" => 10
      }

      {:ok, result} = MyApp.UserQueryable.querify(query, params)
      # result.entries - page 2 (items 11-20)
      # result.metadata.current_page - 2
      # result.metadata.total_pages - total number of pages

  ### Offset-based pagination:

      params = %{
        "offset" => 20,
        "limit" => 10
      }

      {:ok, result} = MyApp.UserQueryable.querify(query, params)
      # result.entries - items 21-30
      # result.metadata.offset - 20

  ## Example 5: Custom Filters with Overrides

      defmodule MyApp.UserQueryable do
        use FatEcto.FatEctoQueryable,
          repo: MyApp.Repo,
          filterable: [
            type: :dynamics,
            fields: [name: ["$ILIKE"], age: ["$GT"]],
            overridable: ["status_active", "email_domain"]
          ],
          sortable: [fields: [name: "*"]],
          paginatable: [type: :offset, default_limit: 20, max_limit: 100]

        import Ecto.Query

        # Custom filter: match only active users
        def override_buildable("status_active", "$EQUAL", "true") do
          dynamic([q], q.status == "active" and not is_nil(q.activated_at))
        end

        # Custom filter: match email domain
        def override_buildable("email_domain", "$EQUAL", domain) do
          pattern = "%@" <> domain
          dynamic([q], fragment("? LIKE ?", q.email, ^pattern))
        end

        def override_buildable(_field, _operator, _value), do: nil
      end

      # Usage:
      params = %{
        "filter" => %{
          "status_active" => %{"$EQUAL" => "true"},
          "email_domain" => %{"$EQUAL" => "example.com"}
        }
      }

      {:ok, result} = MyApp.UserQueryable.querify(query, params)

  ## Example 6: Query-based Filtering (for complex joins)

      defmodule MyApp.PostQueryable do
        use FatEcto.FatEctoQueryable,
          repo: MyApp.Repo,
          filterable: [
            type: :query,
            fields: [title: ["$ILIKE"]],
            overridable: ["has_comments", "author_name"]
          ],
          sortable: [fields: [title: "*", inserted_at: "*"]],
          paginatable: [type: :offset, default_limit: 20, max_limit: 100]

        import Ecto.Query

        # Custom query-based filter with join
        def override_buildable(query, "has_comments", "$EQUAL", "true") do
          from(p in query,
            join: c in assoc(p, :comments),
            distinct: true
          )
        end

        def override_buildable(query, "author_name", "$ILIKE", name) do
          from(p in query,
            join: u in assoc(p, :author),
            where: ilike(u.name, ^name)
          )
        end

        def override_buildable(query, _field, _operator, _value), do: query
      end

      # Usage:
      params = %{
        "filter" => %{
          "has_comments" => %{"$EQUAL" => "true"},
          "author_name" => %{"$ILIKE" => "%John%"}
        }
      }

  ## Example 7: Custom Sorting

      defmodule MyApp.ProductQueryable do
        use FatEcto.FatEctoQueryable,
          repo: MyApp.Repo,
          filterable: [
            type: :dynamics,
            fields: [name: ["$ILIKE"], price: ["$GT", "$LT"]]
          ],
          sortable: [
            fields: [name: "*", price: "*"],
            overridable: ["popularity", "discount"]
          ],
          paginatable: [type: :offset, default_limit: 20, max_limit: 100]

        import Ecto.Query

        # Sort by computed field
        def override_sortable("popularity", "$DESC") do
          {:desc, dynamic([p], p.views * p.sales)}
        end

        # Sort by discount percentage (desc = highest discount first)
        def override_sortable("discount", "$DESC") do
          {:desc, dynamic([p], fragment("(? - ?) / ?::float", p.original_price, p.price, p.original_price))}
        end

        def override_sortable(_field, _operator), do: nil
      end

      # Usage:
      params = %{
        "filter" => %{"price" => %{"$LT" => 100}},
        "sort" => %{"popularity" => "$DESC"}
      }

  ## Example 8: Cursor-based Pagination (for GraphQL/infinite scroll)

      defmodule MyApp.FeedQueryable do
        use FatEcto.FatEctoQueryable,
          repo: MyApp.Repo,
          filterable: [
            type: :dynamics,
            fields: [category: ["$EQUAL"]]
          ],
          sortable: [fields: [inserted_at: "*"]],
          paginatable: [
            type: :cursor,
            cursor_fields: [:inserted_at, :id],
            default_limit: 20,
            max_limit: 100
          ]
      end

      # First page:
      params = %{
        "filter" => %{"category" => %{"$EQUAL" => "tech"}},
        "sort" => %{"inserted_at" => "$DESC"},
        "first" => 20
      }

      {:ok, result} = MyApp.FeedQueryable.querify(query, params)
      # result.entries - first 20 items
      # result.page_info.end_cursor - cursor for next page
      # result.page_info.has_next_page - true/false

      # Next page:
      params = %{
        "filter" => %{"category" => %{"$EQUAL" => "tech"}},
        "first" => 20,
        "after" => result.page_info.end_cursor
      }

  ## Example 9: Ignorable Fields

      defmodule MyApp.SearchQueryable do
        use FatEcto.FatEctoQueryable,
          repo: MyApp.Repo,
          filterable: [
            type: :dynamics,
            fields: [name: ["$ILIKE"], status: ["$EQUAL"]],
            ignorable: [
              name: ["", nil, "%%"],  # Ignore empty/wildcard searches
              status: [nil, ""]
            ]
          ],
          sortable: [fields: [name: "*"]],
          paginatable: [type: :offset, default_limit: 20, max_limit: 100]
      end

      # This will ignore the name filter (empty string):
      params = %{"filter" => %{"name" => %{"$ILIKE" => ""}}}
      {:ok, result} = MyApp.SearchQueryable.querify(query, params)
      # Returns all records (filter was ignored)

  ## Example 10: REST API Integration

      defmodule MyAppWeb.UserController do
        use MyAppWeb, :controller

        def index(conn, params) do
          query = from(u in User)

          case MyApp.UserQueryable.querify(query, params) do
            {:ok, result} ->
              conn
              |> put_resp_header("x-total-count", to_string(result.metadata.total_count))
              |> put_resp_header("x-page", to_string(result.metadata.current_page))
              |> json(%{data: result.entries, metadata: result.metadata})

            {:error, reason} ->
              conn
              |> put_status(:bad_request)
              |> json(%{error: reason})
          end
        end
      end

      # API call: GET /api/users?filter[age][$gt]=25&sort[name]=$asc&page=1&limit=20

  ## Example 11: Global Configuration

  You can configure pagination limits globally in config.exs:

      # config/config.exs
      config :fat_ecto, FatEcto.Pagination.OffsetPaginator,
        default_limit: 25,
        max_limit: 200

      config :fat_ecto, FatEcto.Pagination.CursorPaginator,
        default_limit: 25,
        max_limit: 200

  Then define queryable without limits:

      defmodule MyApp.UserQueryable do
        use FatEcto.FatEctoQueryable,
          repo: MyApp.Repo,
          filterable: [type: :dynamics, fields: [name: ["$ILIKE"]]],
          sortable: [fields: [name: "*"]],
          paginatable: [type: :offset]  # Uses global config
      end

  ## Available Operators

  ### Filter Operators (dynamics-based):
  - `$EQUAL` - Exact match
  - `$NOT_EQUAL` - Not equal
  - `$GT` / `$GTE` - Greater than / Greater than or equal
  - `$LT` / `$LTE` - Less than / Less than or equal
  - `$IN` - Value in list
  - `$LIKE` / `$ILIKE` - Pattern match (case-sensitive/insensitive)
  - `$IS_NULL` - Check for NULL
  - `$NOT_NULL` - Check for NOT NULL

  ### Sort Operators:
  - `$ASC` - Ascending order
  - `$DESC` - Descending order
  - `*` - Allow both ASC and DESC

  ## Return Values

  Offset pagination returns:

      %{
        entries: [%User{}, ...],
        metadata: %{
          total_count: 150,
          current_page: 2,
          page_size: 20,
          total_pages: 8,
          has_next_page: true,
          has_previous_page: true,
          offset: 20,
          entries_count: 20
        }
      }

  Cursor pagination returns:

      %{
        entries: [%Post{}, ...],
        page_info: %{
          has_next_page: true,
          has_previous_page: false,
          start_cursor: "encoded_cursor",
          end_cursor: "encoded_cursor"
        },
        total_count: nil  # or actual count if include_total_count: true
      }
  """

  @doc """
  Callback for custom filtering (dynamics-based).
  """
  @callback override_buildable(field :: String.t(), operator :: String.t(), value :: any()) ::
              Ecto.Query.dynamic_expr() | nil

  @doc """
  Callback for custom filtering (query-based).
  """
  @callback override_buildable(
              query :: Ecto.Query.t(),
              field :: String.t(),
              operator :: String.t(),
              value :: any()
            ) :: Ecto.Query.t()

  @doc """
  Callback for custom sorting.
  """
  @callback override_sortable(field :: String.t(), operator :: String.t()) ::
              FatEcto.Sort.Sorter.order_expr() | nil

  @optional_callbacks override_buildable: 3,
                      override_buildable: 4,
                      override_sortable: 2

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour FatEcto.FatEctoQueryable

      import Ecto.Query
      require Logger
      alias FatEcto.Pagination.CursorPaginator
      alias FatEcto.Pagination.OffsetPaginator
      alias FatEcto.Params.Validator
      alias FatEcto.Query.Buildable, as: QueryBuildable
      alias FatEcto.Query.Dynamics.Buildable, as: DynamicsBuildable
      alias FatEcto.Sort.Sortable

      # Configuration
      @repo Keyword.get(opts, :repo)
      @filterable_config Keyword.get(opts, :filterable, [])
      @sortable_config Keyword.get(opts, :sortable, [])
      @paginatable_config Keyword.get(opts, :paginatable, [])

      # Validate configuration
      unless @repo do
        raise ArgumentError, "repo is required"
      end

      unless @paginatable_config != [] do
        raise ArgumentError, "paginatable configuration is required"
      end

      # Extract config details
      @filter_type Keyword.get(@filterable_config, :type)
      @filterable_fields Keyword.get(@filterable_config, :fields, [])
      @filterable_overridable Keyword.get(@filterable_config, :overridable, [])
      @filterable_ignorable Keyword.get(@filterable_config, :ignorable, [])
      @filterable_unconfigured_fields Keyword.get(@filterable_config, :unconfigured_fields, :raise)
      @filterable_unconfigured_operators Keyword.get(@filterable_config, :unconfigured_operators, :raise)

      @sortable_fields Keyword.get(@sortable_config, :fields, [])
      @sortable_overridable Keyword.get(@sortable_config, :overridable, [])
      @sortable_unconfigured_fields Keyword.get(@sortable_config, :unconfigured_fields, :raise)
      @sortable_unconfigured_operators Keyword.get(@sortable_config, :unconfigured_operators, :raise)

      @pagination_type Keyword.get(@paginatable_config, :type)
      @default_limit Keyword.get(@paginatable_config, :default_limit, 20)
      @max_limit Keyword.get(@paginatable_config, :max_limit, 100)
      @cursor_fields Keyword.get(@paginatable_config, :cursor_fields, [:id])

      @doc """
      Builds a complete query with filtering, sorting, and pagination.

      ## Parameters
      - `queryable` - Ecto schema or query
      - `params` - Map with "filter", "sort", and pagination params
      - `opts` - Additional options (reserved for future use)

      ## Returns
      - `{:ok, %{entries: [...], metadata: %{...}}}` - Success
      - `{:error, reason}` - Validation or execution error
      """
      @spec querify(Ecto.Query.t() | module(), map(), keyword()) ::
              {:ok, map()} | {:error, String.t()}
      def querify(queryable, params \\ %{}, opts \\ [])

      def querify(queryable, params, opts) when is_map(params) do
        query = Ecto.Queryable.to_query(queryable)

        with {:ok, filtered_query} <- apply_filters(query, params, opts),
             {:ok, sorted_query} <- apply_sorting(filtered_query, params, opts) do
          apply_pagination(sorted_query, params, opts)
        end
      end

      def querify(_queryable, _params, _opts) do
        {:error, "params must be a map"}
      end

      # ========================================================================
      # FILTERING
      # ========================================================================

      # Helper to apply filters only if filter params are present
      defp apply_filters_if_present(query, params, filter_fn) do
        filter_params = Map.get(params, "filter", %{})

        if map_size(filter_params) == 0 do
          {:ok, query}
        else
          filter_fn.(query, filter_params)
        end
      end

      if @filter_type == :dynamics do
        defp apply_filters(query, params, _opts) do
          apply_filters_if_present(query, params, &apply_filterable/2)
        end

        defp apply_filterable(query, filter_params) do
          # Validate if unconfigured_fields or unconfigured_operators is not :ignore
          with {:ok, _} <- validate_filter_params_if_needed(filter_params) do
            buildable_opts = [
              filterable: @filterable_fields,
              overrideable: @filterable_overridable,
              ignoreable: @filterable_ignorable
            ]

            dynamics =
              DynamicsBuildable.build(
                filter_params,
                buildable_opts,
                &override_buildable/3
              )

            filtered_query = if dynamics, do: from(q in query, where: ^dynamics), else: query
            {:ok, filtered_query}
          end
        rescue
          e -> {:error, "Filter error: #{inspect(e)}"}
        end

        def override_buildable(_field, _operator, _value), do: nil
        defoverridable override_buildable: 3
      end

      if @filter_type == :query do
        defp apply_filters(query, params, _opts) do
          apply_filters_if_present(query, params, &apply_filterable/2)
        end

        defp apply_filterable(query, filter_params) do
          # Validate if unconfigured_fields or unconfigured_operators is not :ignore
          with {:ok, _} <- validate_filter_params_if_needed(filter_params) do
            buildable_opts = [
              filterable: @filterable_fields,
              overrideable: @filterable_overridable,
              ignoreable: @filterable_ignorable
            ]

            filtered_query =
              QueryBuildable.build(
                query,
                filter_params,
                buildable_opts,
                &override_buildable(&1, &2, &3, &4)
              )

            {:ok, filtered_query}
          end
        rescue
          e -> {:error, "Filter error: #{inspect(e)}"}
        end

        def override_buildable(query, _field, _operator, _value), do: query
        defoverridable override_buildable: 4
      end

      if @filter_type == nil do
        defp apply_filters(query, _params, _opts), do: {:ok, query}
      end

      # ========================================================================
      # SORTING
      # ========================================================================

      if @sortable_fields != [] or @sortable_overridable != [] do
        defp apply_sorting(query, params, _opts) do
          sort_params = Map.get(params, "sort", %{})

          if map_size(sort_params) == 0 do
            {:ok, query}
          else
            apply_inline_sort(query, sort_params)
          end
        end

        defp apply_inline_sort(query, sort_params) do
          # Validate if unconfigured_fields or unconfigured_operators is not :ignore
          with {:ok, _} <- validate_sort_params_if_needed(sort_params) do
            # Build options for Sortable
            sortable_opts = [
              sortable: @sortable_fields,
              overrideable: @sortable_overridable
            ]

            # Use Sortable.build directly - no duplication!
            order_by_exprs =
              Sortable.build(
                sort_params,
                sortable_opts,
                &override_sortable/2
              )

            sorted_query = from(q in query, order_by: ^order_by_exprs)
            {:ok, sorted_query}
          end
        rescue
          e -> {:error, "Sort error: #{inspect(e)}"}
        end

        # Default override callback
        def override_sortable(_field, _operator), do: nil
        defoverridable override_sortable: 2
      else
        defp apply_sorting(query, _params, _opts), do: {:ok, query}
      end

      # ========================================================================
      # PAGINATION
      # ========================================================================

      if @pagination_type == :offset do
        defp apply_pagination(query, params, _opts) do
          # Call OffsetPaginator.paginate/4 directly - no duplication!
          paginator_opts = [
            default_limit: @default_limit,
            max_limit: @max_limit
          ]

          OffsetPaginator.paginate(query, params, @repo, paginator_opts)
        end
      end

      if @pagination_type == :cursor do
        defp apply_pagination(query, params, _opts) do
          # Call CursorPaginator.paginate/4 directly - no duplication!
          # Merge cursor_fields into params if not already present
          params_with_cursor_fields =
            if Map.has_key?(params, :cursor_fields) or Map.has_key?(params, "cursor_fields") do
              params
            else
              Map.put(params, :cursor_fields, @cursor_fields)
            end

          paginator_opts = [
            default_limit: @default_limit,
            max_limit: @max_limit
          ]

          case CursorPaginator.paginate(
                 query,
                 params_with_cursor_fields,
                 @repo,
                 paginator_opts
               ) do
            {:ok, %{edges: edges, page_info: page_info, total_count: total_count}} ->
              # Transform Relay-style edges to entries for backward compatibility
              entries = Enum.map(edges, & &1.node)
              {:ok, %{entries: entries, page_info: page_info, total_count: total_count}}

            {:error, _} = error ->
              error
          end
        end
      end

      # ========================================================================
      # VALIDATION HELPERS
      # ========================================================================

      defp validate_filter_params_if_needed(filter_params) do
        # Skip validation if both behaviors are :ignore
        if @filterable_unconfigured_fields == :ignore and @filterable_unconfigured_operators == :ignore do
          {:ok, filter_params}
        else
          # Convert filterable fields to map format expected by validator
          filterable_fields_map =
            Enum.into(@filterable_fields, %{}, fn {field, operators} ->
              {to_string(field), Enum.map(operators, &to_string/1)}
            end)

          # Add overridable fields to filterable map with all operators
          filterable_with_overrides =
            Enum.reduce(@filterable_overridable, filterable_fields_map, fn field, acc ->
              Map.put(acc, to_string(field), "*")
            end)

          validator_opts = [
            filterable_fields: filterable_with_overrides,
            unconfigured_fields: @filterable_unconfigured_fields,
            unconfigured_operators: @filterable_unconfigured_operators
          ]

          Validator.validate_filters(filter_params, validator_opts)
        end
      end

      defp validate_sort_params_if_needed(sort_params) do
        # Skip validation if both behaviors are :ignore
        if @sortable_unconfigured_fields == :ignore and @sortable_unconfigured_operators == :ignore do
          {:ok, sort_params}
        else
          # Convert sortable fields to map format expected by validator
          sortable_fields_map =
            Enum.into(@sortable_fields, %{}, fn {field, operators} ->
              field_str = to_string(field)
              operators_normalized = if operators == "*", do: "*", else: Enum.map(operators, &to_string/1)
              {field_str, operators_normalized}
            end)

          # Add overridable fields to sortable map with all operators
          sortable_with_overrides =
            Enum.reduce(@sortable_overridable, sortable_fields_map, fn field, acc ->
              Map.put(acc, to_string(field), "*")
            end)

          validator_opts = [
            sortable_fields: sortable_with_overrides,
            unconfigured_fields: @sortable_unconfigured_fields,
            unconfigured_operators: @sortable_unconfigured_operators
          ]

          Validator.validate_sort(sort_params, validator_opts)
        end
      end
    end
  end
end
