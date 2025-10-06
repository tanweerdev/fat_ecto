defmodule FatEcto.Pagination.CursorPaginatorTest do
  use FatEcto.ConnCase

  import Ecto.Query

  alias FatEcto.FatUser
  alias FatEcto.Pagination.CursorPaginator
  alias FatEcto.Repo

  @moduletag :pagination

  # Define test paginator
  defmodule TestCursorPaginator do
    use FatEcto.Pagination.CursorPaginator,
      repo: FatEcto.Repo,
      default_limit: 10,
      max_limit: 50
  end

  setup do
    # Create test users with specific timestamps for cursor testing
    base_time = ~U[2024-01-01 00:00:00Z]

    users =
      for i <- 1..30 do
        created_at = DateTime.add(base_time, i * 60, :second)

        Repo.insert!(%FatUser{
          name: "User #{String.pad_leading(Integer.to_string(i), 2, "0")}",
          email: "user#{i}@example.com",
          age: 20 + rem(i, 30),
          created_at: created_at
        })
      end

    {:ok, users: users}
  end

  describe "paginate/2 forward pagination (first/after)" do
    test "fetches first page without cursor", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} =
               TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10)

      assert length(result.edges) == 10
      assert result.page_info.has_next_page == true
      assert result.page_info.has_previous_page == false
      assert result.page_info.start_cursor != nil
      assert result.page_info.end_cursor != nil
    end

    test "fetches subsequent page using cursor", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      # Get first page
      {:ok, page1} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10)

      # Get next page using end_cursor
      {:ok, page2} =
        TestCursorPaginator.paginate(query,
          cursor_fields: [:id],
          first: 10,
          after: page1.page_info.end_cursor
        )

      assert length(page2.edges) == 10
      assert page2.page_info.has_previous_page == true
      assert page2.page_info.has_next_page == true

      # Ensure no overlap between pages
      page1_ids = Enum.map(page1.edges, & &1.node.id)
      page2_ids = Enum.map(page2.edges, & &1.node.id)
      assert MapSet.disjoint?(MapSet.new(page1_ids), MapSet.new(page2_ids))
    end

    test "detects last page correctly", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      # Jump to near the end
      {:ok, page1} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 20)

      {:ok, page2} =
        TestCursorPaginator.paginate(query,
          cursor_fields: [:id],
          first: 20,
          after: page1.page_info.end_cursor
        )

      # Only 10 left
      assert length(page2.edges) == 10
      assert page2.page_info.has_next_page == false
      assert page2.page_info.has_previous_page == true
    end

    test "handles composite cursor fields", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.age, asc: u.id])

      {:ok, result} =
        TestCursorPaginator.paginate(query, cursor_fields: [:age, :id], first: 10)

      assert length(result.edges) == 10
      assert result.page_info.start_cursor != nil

      # Verify cursors are present
      assert result.page_info.start_cursor != nil

      # Decode cursor to verify it contains both fields
      {:ok, cursor_data} = TestCursorPaginator.decode_cursor(result.page_info.start_cursor)
      assert Map.has_key?(cursor_data, :age)
      assert Map.has_key?(cursor_data, :id)
    end
  end

  describe "paginate/2 backward pagination (last/before)" do
    test "fetches last page without cursor", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], last: 10)

      assert length(result.edges) == 10
      assert result.page_info.has_next_page == false
      assert result.page_info.has_previous_page == true
    end

    test "fetches previous page using cursor", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      # Get last page
      {:ok, last_page} = TestCursorPaginator.paginate(query, cursor_fields: [:id], last: 10)

      # Get previous page using start_cursor
      {:ok, prev_page} =
        TestCursorPaginator.paginate(query,
          cursor_fields: [:id],
          last: 10,
          before: last_page.page_info.start_cursor
        )

      assert length(prev_page.edges) == 10
      assert prev_page.page_info.has_previous_page == true
      assert prev_page.page_info.has_next_page == true

      # Ensure no overlap
      last_ids = Enum.map(last_page.edges, & &1.node.id)
      prev_ids = Enum.map(prev_page.edges, & &1.node.id)
      assert MapSet.disjoint?(MapSet.new(last_ids), MapSet.new(prev_ids))
    end
  end

  describe "encode_cursor/2 and decode_cursor/1" do
    test "encodes and decodes cursor correctly", %{users: [user | _]} do
      cursor = TestCursorPaginator.encode_cursor(user, [:id, :created_at])

      assert is_binary(cursor)
      # Base64 encoded string check
      assert is_binary(cursor)

      {:ok, decoded} = TestCursorPaginator.decode_cursor(cursor)

      assert decoded.id == user.id
      assert decoded.created_at == user.created_at
    end

    test "handles datetime serialization" do
      user =
        Repo.insert!(%FatUser{
          name: "Test User",
          email: "test@example.com",
          created_at: ~U[2024-01-15 10:30:00Z]
        })

      cursor = TestCursorPaginator.encode_cursor(user, [:id, :created_at])
      {:ok, decoded} = TestCursorPaginator.decode_cursor(cursor)

      assert decoded.id == user.id
      assert decoded.created_at == user.created_at
    end

    test "rejects invalid cursor" do
      assert {:error, _} = TestCursorPaginator.decode_cursor("invalid_cursor")
    end

    test "rejects malformed base64" do
      assert {:error, _} = TestCursorPaginator.decode_cursor("not@valid@base64!")
    end

    test "handles nil cursor" do
      assert {:ok, nil} = TestCursorPaginator.decode_cursor(nil)
    end
  end

  describe "parameter validation" do
    test "requires cursor_fields parameter" do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:error, message} = TestCursorPaginator.paginate(query, first: 10)
      assert message =~ "cursor_fields is required"
    end

    test "rejects empty cursor_fields" do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:error, message} =
               TestCursorPaginator.paginate(query, cursor_fields: [], first: 10)

      assert message =~ "cursor_fields cannot be empty"
    end

    test "rejects non-list cursor_fields" do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:error, message} =
               TestCursorPaginator.paginate(query, cursor_fields: :id, first: 10)

      assert message =~ "must be a list"
    end

    test "rejects both first and last parameters" do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:error, message} =
               TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10, last: 10)

      assert message =~ "Cannot specify both"
    end

    test "rejects limit exceeding max_limit" do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:error, message} =
               TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 100)

      assert message =~ "exceeds maximum"
    end

    test "rejects limit below minimum" do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:error, message} =
               TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 0)

      assert message =~ "must be at least"
    end

    test "handles string parameters" do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} =
               TestCursorPaginator.paginate(query, %{"cursor_fields" => [:id], "first" => "10"})

      assert length(result.edges) == 10
    end
  end

  describe "edge structure (Relay-compliant)" do
    test "each edge has cursor and node", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 5)

      for edge <- result.edges do
        assert Map.has_key?(edge, :cursor)
        assert Map.has_key?(edge, :node)
        assert is_binary(edge.cursor)
        assert %FatUser{} = edge.node
      end
    end

    test "cursors are unique per edge", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10)

      cursors = Enum.map(result.edges, & &1.cursor)
      unique_cursors = Enum.uniq(cursors)

      assert length(cursors) == length(unique_cursors)
    end
  end

  describe "page_info structure (Relay-compliant)" do
    test "contains all required fields", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10)

      page_info = result.page_info

      assert Map.has_key?(page_info, :has_next_page)
      assert Map.has_key?(page_info, :has_previous_page)
      assert Map.has_key?(page_info, :start_cursor)
      assert Map.has_key?(page_info, :end_cursor)

      assert is_boolean(page_info.has_next_page)
      assert is_boolean(page_info.has_previous_page)
    end

    test "cursors match first and last edges", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10)

      first_edge = List.first(result.edges)
      last_edge = List.last(result.edges)

      assert result.page_info.start_cursor == first_edge.cursor
      assert result.page_info.end_cursor == last_edge.cursor
    end

    test "handles empty results", %{users: _users} do
      query = from(u in FatUser, where: u.id == -1)

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10)

      assert result.edges == []
      assert result.page_info.start_cursor == nil
      assert result.page_info.end_cursor == nil
      assert result.page_info.has_next_page == false
      assert result.page_info.has_previous_page == false
    end
  end

  describe "total_count option" do
    test "excludes total_count by default", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10)

      assert is_nil(result.total_count)
    end

    test "includes total_count when requested", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} =
        TestCursorPaginator.paginate(query,
          cursor_fields: [:id],
          first: 10,
          include_total_count: true
        )

      assert result.total_count == 30
    end

    test "total_count respects query filters", %{users: _users} do
      query = from(u in FatUser, where: u.age > 30, order_by: [asc: u.id])

      {:ok, result} =
        TestCursorPaginator.paginate(query,
          cursor_fields: [:id],
          first: 10,
          include_total_count: true
        )

      assert result.total_count < 30
    end
  end

  describe "consistency across pagination" do
    test "navigating forward maintains consistency", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      # Collect all IDs by paginating through
      all_ids =
        Stream.unfold(nil, fn
          # Stop signal - end the stream
          :done ->
            nil

          # Regular cursor (including nil for first page)
          cursor ->
            params =
              if cursor do
                [cursor_fields: [:id], first: 5, after: cursor]
              else
                [cursor_fields: [:id], first: 5]
              end

            case TestCursorPaginator.paginate(query, params) do
              {:ok, result} ->
                ids = Enum.map(result.edges, & &1.node.id)

                if result.page_info.has_next_page do
                  # More pages - continue with next cursor
                  {ids, result.page_info.end_cursor}
                else
                  # Last page - return ids and signal done
                  {ids, :done}
                end

              {:error, _} ->
                nil
            end
        end)

      all_ids = all_ids |> Enum.to_list() |> List.flatten()

      # Should get all 30 users
      assert length(all_ids) == 30
      # Should be in order
      assert all_ids == Enum.sort(all_ids)
      # Should have no duplicates
      assert length(Enum.uniq(all_ids)) == 30
    end
  end

  describe "edge cases" do
    test "handles single result" do
      Repo.delete_all(FatUser)
      user = Repo.insert!(%FatUser{name: "Solo", email: "solo@example.com"})

      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 10)

      assert length(result.edges) == 1
      assert hd(result.edges).node.id == user.id
      assert result.page_info.has_next_page == false
      assert result.page_info.has_previous_page == false
    end

    test "handles limit larger than dataset", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      {:ok, result} = TestCursorPaginator.paginate(query, cursor_fields: [:id], first: 50)

      assert length(result.edges) == 30
      assert result.page_info.has_next_page == false
    end
  end

  describe "application configuration" do
    test "uses application config for default_limit and max_limit", _context do
      # Clean up existing users first
      Repo.delete_all(FatUser)

      # Set application config
      Application.put_env(:fat_ecto, FatEcto.Pagination.CursorPaginator,
        default_limit: 5,
        max_limit: 25
      )

      # Create test users
      for i <- 1..20 do
        Repo.insert!(%FatUser{
          name: "User #{i}",
          email: "user#{i}@example.com",
          age: 20 + i
        })
      end

      query = from(u in FatUser, order_by: [asc: u.id])

      # Test default_limit from app config (when no first/last specified)
      {:ok, result} = CursorPaginator.paginate(query, %{cursor_fields: [:id]}, Repo, [])
      assert length(result.edges) == 5

      # Test that explicit options override app config
      {:ok, result} = CursorPaginator.paginate(query, %{cursor_fields: [:id]}, Repo, default_limit: 10)
      assert length(result.edges) == 10

      # Test max_limit from app config
      {:error, error} = CursorPaginator.paginate(query, %{cursor_fields: [:id], first: 30}, Repo, [])
      assert error =~ "exceeds maximum allowed value of 25"

      # Test that explicit max_limit overrides app config
      {:ok, result} = CursorPaginator.paginate(query, %{cursor_fields: [:id], first: 30}, Repo, max_limit: 50)
      assert length(result.edges) == 20

      # Clean up
      Application.delete_env(:fat_ecto, FatEcto.Pagination.CursorPaginator)
    end

    test "macro usage respects application config", _context do
      # Clean up existing users first
      Repo.delete_all(FatUser)

      # Set application config
      Application.put_env(:fat_ecto, FatEcto.Pagination.CursorPaginator,
        default_limit: 3,
        max_limit: 15
      )

      # Create test users
      for i <- 1..10 do
        Repo.insert!(%FatUser{
          name: "User #{i}",
          email: "user#{i}@example.com",
          age: 20 + i
        })
      end

      # Define paginator without explicit limits - should use app config
      defmodule TestAppConfigCursorPaginator do
        use FatEcto.Pagination.CursorPaginator,
          repo: FatEcto.Repo
      end

      query = from(u in FatUser, order_by: [asc: u.id])

      # Should use default_limit from app config (3)
      {:ok, result} = TestAppConfigCursorPaginator.paginate(query, cursor_fields: [:id])
      assert length(result.edges) == 3

      # Should respect max_limit from app config (15)
      {:error, error} = TestAppConfigCursorPaginator.paginate(query, cursor_fields: [:id], first: 20)
      assert error =~ "exceeds maximum allowed value of 15"

      # Clean up
      Application.delete_env(:fat_ecto, FatEcto.Pagination.CursorPaginator)
    end

    test "repo can be configured via global application config", _context do
      # Clean up existing users first
      Repo.delete_all(FatUser)

      # Set global application config with repo
      Application.put_env(:fat_ecto, FatEcto.Pagination.CursorPaginator,
        repo: FatEcto.Repo,
        default_limit: 5,
        max_limit: 50
      )

      # Create test users
      for i <- 1..10 do
        Repo.insert!(%FatUser{
          name: "User #{i}",
          email: "user#{i}@example.com",
          age: 20 + i
        })
      end

      # Define paginator without explicit repo - should use global app config
      defmodule TestGlobalRepoConfigCursorPaginator do
        use FatEcto.Pagination.CursorPaginator
      end

      query = from(u in FatUser, order_by: [asc: u.id])

      # Should work with repo from global app config
      {:ok, result} = TestGlobalRepoConfigCursorPaginator.paginate(query, cursor_fields: [:id])
      assert length(result.edges) == 5

      # Clean up
      Application.delete_env(:fat_ecto, FatEcto.Pagination.CursorPaginator)
    end
  end
end
