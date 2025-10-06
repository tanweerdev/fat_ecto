defmodule FatEcto.FatEctoQueryableTest do
  use FatEcto.ConnCase

  import Ecto.Query

  alias FatEcto.FatUser
  alias FatEcto.Pagination.CursorPaginator
  alias FatEcto.Repo

  @moduletag :queryable

  # Test queryable with dynamics filtering and offset pagination
  defmodule TestDynamicsOffsetQueryable do
    use FatEcto.FatEctoQueryable,
      repo: FatEcto.Repo,
      filterable: [
        type: :dynamics,
        fields: [
          id: ["$EQUAL", "$NOT_EQUAL", "$IN"],
          name: ["$ILIKE", "$LIKE"],
          age: ["$GT", "$GTE", "$LT", "$LTE"],
          email: ["$EQUAL"]
        ],
        ignorable: [name: ["%%", "", [], nil]],
        overridable: ["custom_field"]
      ],
      sortable: [
        fields: [name: "*", age: ["$ASC", "$DESC"], id: "*"],
        overridable: ["custom_sort"]
      ],
      paginatable: [
        type: :offset,
        default_limit: 10,
        max_limit: 50
      ]

    import Ecto.Query

    @spec override_filter(String.t(), String.t(), any()) :: Ecto.Query.dynamic_expr() | nil
    def override_filter("custom_field", "$EQUAL", value) do
      dynamic([q], fragment("?->>'custom'", q.name) == ^value)
    end

    @spec override_filter(String.t(), String.t(), any()) :: Ecto.Query.dynamic_expr() | nil
    def override_filter(_field, _operator, _value), do: nil

    @spec override_sort(String.t(), String.t()) ::
            {atom(), Ecto.Query.dynamic_expr()} | nil
    def override_sort("custom_sort", "$ASC") do
      {:asc, dynamic([q], q.id)}
    end

    @spec override_sort(String.t(), String.t()) ::
            {atom(), Ecto.Query.dynamic_expr()} | nil
    def override_sort(_field, _operator), do: nil
  end

  # Test queryable with query filtering and cursor pagination
  defmodule TestQueryCursorQueryable do
    use FatEcto.FatEctoQueryable,
      repo: FatEcto.Repo,
      filterable: [
        type: :query,
        fields: [
          id: ["$EQUAL"],
          age: ["$GT", "$LT"]
        ],
        overridable: []
      ],
      sortable: [
        fields: [id: "*", age: "*"]
      ],
      paginatable: [
        type: :cursor,
        cursor_fields: [:id],
        default_limit: 10,
        max_limit: 50
      ]

    @spec override_filter(Ecto.Query.t(), String.t(), String.t(), any()) :: Ecto.Query.t()
    def override_filter(query, _field, _operator, _value), do: query
  end

  setup do
    # Create 30 test users
    users =
      for i <- 1..30 do
        Repo.insert!(%FatUser{
          name: "User #{i}",
          email: "user#{i}@example.com",
          age: 20 + rem(i, 30),
          city: "City #{rem(i, 5)}",
          status: if(rem(i, 2) == 0, do: "active", else: "inactive")
        })
      end

    {:ok, users: users}
  end

  describe "FatEctoQueryable with dynamics filtering and offset pagination" do
    test "builds query with filtering, sorting, and pagination", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{"age" => %{"$GT" => 25}},
        "sort" => %{"name" => "$DESC"},
        "page" => 1,
        "limit" => 5
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      assert length(result.entries) <= 5
      assert result.metadata.current_page == 1
      assert is_integer(result.metadata.total_count)
    end

    test "builds query with only filtering", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{"age" => %{"$LTE" => 30}}
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      assert length(result.entries) <= 10
      assert result.metadata.current_page == 1
    end

    test "builds query with only sorting", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "sort" => %{"age" => "$ASC", "name" => "$DESC"}
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      assert length(result.entries) <= 10
    end

    test "builds query with only pagination", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "page" => 2,
        "limit" => 10
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      assert length(result.entries) <= 10
      assert result.metadata.current_page == 2
    end

    test "handles empty params", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, %{})
      assert length(result.entries) <= 10
      assert result.metadata.total_count == 30
    end

    test "respects ignorable fields", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{"name" => %{"$ILIKE" => "%%"}},
        "page" => 1,
        "limit" => 10
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      # Should ignore the filter and return all users
      assert result.metadata.total_count == 30
    end

    test "handles $IN operator", %{users: users} do
      query = from(u in FatUser)
      ids = Enum.map(Enum.take(users, 3), & &1.id)

      params = %{
        "filter" => %{"id" => %{"$IN" => ids}},
        "page" => 1,
        "limit" => 10
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      assert result.metadata.total_count == 3
      assert length(result.entries) == 3
    end

    test "handles multiple filters", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "age" => %{"$GTE" => 25, "$LTE" => 35},
          "name" => %{"$ILIKE" => "%User%"}
        },
        "page" => 1,
        "limit" => 20
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      assert is_list(result.entries)
      assert is_map(result.metadata)
    end

    test "validates pagination parameters", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "page" => -1,
        "limit" => 10
      }

      assert {:error, reason} = TestDynamicsOffsetQueryable.querify(query, params)
      assert reason =~ "page must be at least 1"
    end

    test "validates limit exceeds max", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "limit" => 100
      }

      assert {:error, reason} = TestDynamicsOffsetQueryable.querify(query, params)
      assert reason =~ "limit exceeds maximum allowed value"
    end

    test "handles offset-style pagination", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      params = %{
        "offset" => 10,
        "limit" => 5
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      assert length(result.entries) == 5
      assert result.metadata.offset == 10
    end

    test "combines all features", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "filter" => %{
          "age" => %{"$GT" => 20}
        },
        "sort" => %{
          "age" => "$ASC",
          "name" => "$DESC"
        },
        "page" => 1,
        "limit" => 15
      }

      assert {:ok, result} = TestDynamicsOffsetQueryable.querify(query, params)
      assert is_list(result.entries)
      assert length(result.entries) <= 15
      assert result.metadata.current_page == 1
      assert result.metadata.page_size == 15
    end
  end

  describe "FatEctoQueryable with query filtering and cursor pagination" do
    test "builds query with cursor pagination", %{users: users} do
      query = from(u in FatUser, order_by: [asc: u.id])
      first_user = List.first(users)

      # Encode cursor for first user using proper cursor encoding
      cursor = CursorPaginator.encode_cursor(first_user, [:id])

      params = %{
        "filter" => %{"age" => %{"$GT" => 20}},
        "sort" => %{"id" => "$ASC"},
        "first" => 10,
        "after" => cursor
      }

      assert {:ok, result} = TestQueryCursorQueryable.querify(query, params)
      assert is_list(result.entries)
      assert length(result.entries) <= 10
      assert is_map(result.page_info)
      assert is_boolean(result.page_info.has_next_page)
    end

    test "handles forward pagination", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      params = %{
        "first" => 5
      }

      assert {:ok, result} = TestQueryCursorQueryable.querify(query, params)
      assert length(result.entries) == 5
      assert result.page_info.has_next_page == true
      assert is_binary(result.page_info.start_cursor)
      assert is_binary(result.page_info.end_cursor)
    end

    test "handles backward pagination", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      params = %{
        "last" => 5
      }

      assert {:ok, result} = TestQueryCursorQueryable.querify(query, params)
      assert length(result.entries) == 5
      assert result.page_info.has_previous_page == true
    end

    test "validates cannot specify both first and last", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "first" => 10,
        "last" => 10
      }

      assert {:error, reason} = TestQueryCursorQueryable.querify(query, params)
      assert reason =~ "Cannot specify both 'first' and 'last'"
    end

    test "validates cursor limit exceeds max", %{users: _users} do
      query = from(u in FatUser)

      params = %{
        "first" => 100
      }

      assert {:error, reason} = TestQueryCursorQueryable.querify(query, params)
      assert reason =~ "Limit exceeds maximum allowed value"
    end

    test "handles empty results with cursor", %{users: _users} do
      query = from(u in FatUser, where: u.id == -1, order_by: [asc: u.id])

      params = %{
        "first" => 10
      }

      assert {:ok, result} = TestQueryCursorQueryable.querify(query, params)
      assert result.entries == []
      assert result.page_info.has_next_page == false
      assert is_nil(result.page_info.start_cursor)
      assert is_nil(result.page_info.end_cursor)
    end
  end

  describe "FatEctoQueryable with invalid params" do
    test "returns error for non-map params" do
      query = from(u in FatUser)

      assert {:error, reason} = TestDynamicsOffsetQueryable.querify(query, "invalid")
      assert reason == "params must be a map"
    end

    test "returns error for invalid offset" do
      query = from(u in FatUser)

      params = %{
        "offset" => -10
      }

      assert {:error, reason} = TestDynamicsOffsetQueryable.querify(query, params)
      assert reason =~ "offset must be non-negative"
    end
  end
end
