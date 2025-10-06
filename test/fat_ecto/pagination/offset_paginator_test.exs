defmodule FatEcto.Pagination.OffsetPaginatorTest do
  use FatEcto.ConnCase

  import Ecto.Query

  alias FatEcto.FatUser
  alias FatEcto.Pagination.OffsetPaginator
  alias FatEcto.Repo

  @moduletag :pagination

  # Define test paginator
  defmodule TestOffsetPaginator do
    use FatEcto.Pagination.OffsetPaginator,
      repo: FatEcto.Repo,
      default_limit: 10,
      max_limit: 50
  end

  setup do
    # Create 55 test users
    users =
      for i <- 1..55 do
        Repo.insert!(%FatUser{
          name: "User #{i}",
          email: "user#{i}@example.com",
          age: 20 + rem(i, 30)
        })
      end

    {:ok, users: users}
  end

  describe "paginate/2 with offset/limit style" do
    test "paginates with default limit", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestOffsetPaginator.paginate(query, offset: 0)
      assert length(result.entries) == 10
      assert result.metadata.total_count == 55
      assert result.metadata.current_page == 1
      assert result.metadata.total_pages == 6
      assert result.metadata.has_next_page == true
      assert result.metadata.has_previous_page == false
    end

    test "paginates second page with offset", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestOffsetPaginator.paginate(query, offset: 10, limit: 10)
      assert length(result.entries) == 10
      assert result.metadata.current_page == 2
      assert result.metadata.has_next_page == true
      assert result.metadata.has_previous_page == true
    end

    test "paginates last page correctly", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestOffsetPaginator.paginate(query, offset: 50, limit: 10)
      assert length(result.entries) == 5
      assert result.metadata.current_page == 6
      assert result.metadata.has_next_page == false
      assert result.metadata.has_previous_page == true
      assert result.metadata.is_last_page == true
    end

    test "handles empty results", %{users: _users} do
      query = from(u in FatUser, where: u.id == -1)

      assert {:ok, result} = TestOffsetPaginator.paginate(query, offset: 0, limit: 10)
      assert result.entries == []
      assert result.metadata.total_count == 0
      assert result.metadata.has_next_page == false
      assert result.metadata.has_previous_page == false
    end

    test "respects custom limit", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestOffsetPaginator.paginate(query, offset: 0, limit: 25)
      assert length(result.entries) == 25
      assert result.metadata.total_pages == 3
    end
  end

  describe "paginate/2 with page/page_size style" do
    test "paginates first page", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestOffsetPaginator.paginate(query, page: 1, page_size: 10)
      assert length(result.entries) == 10
      assert result.metadata.current_page == 1
      assert result.metadata.offset == 0
      assert result.metadata.is_first_page == true
    end

    test "paginates third page", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestOffsetPaginator.paginate(query, page: 3, page_size: 20)
      # 55 - (2 * 20) = 15 remaining
      assert length(result.entries) == 15
      assert result.metadata.current_page == 3
      assert result.metadata.offset == 40
    end

    test "page takes precedence over offset when both provided", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} =
               TestOffsetPaginator.paginate(query, page: 2, offset: 99, page_size: 10)

      assert result.metadata.current_page == 2
      # Calculated from page 2
      assert result.metadata.offset == 10
    end
  end

  describe "validate_params/1" do
    test "validates correct offset/limit params" do
      assert {:ok, params} = TestOffsetPaginator.validate_params(offset: 10, limit: 20)
      assert params.offset == 10
      assert params.limit == 20
    end

    test "validates correct page/page_size params" do
      assert {:ok, params} = TestOffsetPaginator.validate_params(page: 2, page_size: 15)
      # (page - 1) * page_size
      assert params.offset == 15
      assert params.limit == 15
    end

    test "applies default limit when not provided" do
      assert {:ok, params} = TestOffsetPaginator.validate_params(offset: 0)
      # default_limit
      assert params.limit == 10
    end

    test "rejects limit exceeding max_limit" do
      assert {:error, message} = TestOffsetPaginator.validate_params(limit: 100)
      assert message =~ "exceeds maximum"
    end

    test "rejects negative offset" do
      assert {:error, message} = TestOffsetPaginator.validate_params(offset: -5, limit: 10)
      assert message =~ "must be non-negative"
    end

    test "rejects page less than 1" do
      assert {:error, message} = TestOffsetPaginator.validate_params(page: 0, page_size: 10)
      assert message =~ "must be at least 1"
    end

    test "rejects limit less than minimum" do
      assert {:error, message} = TestOffsetPaginator.validate_params(limit: 0)
      assert message =~ "must be at least 1"
    end

    test "handles string parameters" do
      assert {:ok, params} = TestOffsetPaginator.validate_params(offset: "20", limit: "15")
      assert params.offset == 20
      assert params.limit == 15
    end

    test "handles map with string keys" do
      assert {:ok, params} =
               TestOffsetPaginator.validate_params(%{"offset" => "10", "limit" => "20"})

      assert params.offset == 10
      assert params.limit == 20
    end
  end

  describe "count_records/1" do
    test "counts total records", %{users: _users} do
      query = from(u in FatUser)
      assert TestOffsetPaginator.count_records(query) == 55
    end

    test "counts filtered records", %{users: _users} do
      query = from(u in FatUser, where: u.age > 40)
      count = TestOffsetPaginator.count_records(query)
      assert count < 55
      assert count > 0
    end

    test "excludes pagination clauses from count", %{users: _users} do
      query = from(u in FatUser, limit: 10, offset: 5)
      # Count should ignore limit/offset
      assert TestOffsetPaginator.count_records(query) == 55
    end
  end

  describe "metadata" do
    test "includes all expected fields", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestOffsetPaginator.paginate(query, page: 2, page_size: 20)

      metadata = result.metadata

      assert Map.has_key?(metadata, :total_count)
      assert Map.has_key?(metadata, :total_pages)
      assert Map.has_key?(metadata, :current_page)
      assert Map.has_key?(metadata, :page_size)
      assert Map.has_key?(metadata, :offset)
      assert Map.has_key?(metadata, :has_next_page)
      assert Map.has_key?(metadata, :has_previous_page)
      assert Map.has_key?(metadata, :is_first_page)
      assert Map.has_key?(metadata, :is_last_page)
      assert Map.has_key?(metadata, :start_cursor)
      assert Map.has_key?(metadata, :end_cursor)
      assert Map.has_key?(metadata, :entries_count)
    end

    test "calculates cursors correctly", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} = TestOffsetPaginator.paginate(query, offset: 10, limit: 5)

      assert result.metadata.start_cursor == 10
      assert result.metadata.end_cursor == 15
      assert result.metadata.entries_count == 5
    end

    test "handles without total count when include_total_count is false", %{users: _users} do
      query = from(u in FatUser, order_by: [asc: u.id])

      assert {:ok, result} =
               TestOffsetPaginator.paginate(query, offset: 10, limit: 10, include_total_count: false)

      assert is_nil(result.metadata.total_count)
      assert is_nil(result.metadata.total_pages)
      # Should still have has_next_page based on entries returned
      assert result.metadata.has_next_page == true
    end
  end

  describe "edge cases" do
    test "handles empty database" do
      # Delete all users
      Repo.delete_all(FatUser)

      query = from(u in FatUser)

      assert {:ok, result} = TestOffsetPaginator.paginate(query)
      assert result.entries == []
      assert result.metadata.total_count == 0
      assert result.metadata.total_pages == 0
    end

    test "handles single page of results" do
      # Create exactly 5 users for this test
      Repo.delete_all(FatUser)

      for i <- 1..5 do
        Repo.insert!(%FatUser{
          name: "User #{i}",
          email: "single#{i}@example.com"
        })
      end

      query = from(u in FatUser)

      assert {:ok, result} = TestOffsetPaginator.paginate(query, page_size: 10)
      assert length(result.entries) == 5
      assert result.metadata.total_pages == 1
      assert result.metadata.is_first_page == true
      assert result.metadata.is_last_page == true
    end

    test "handles exact page boundary", %{users: _users} do
      # Create exactly 50 users scenario
      Repo.delete_all(FatUser)

      for i <- 1..50 do
        Repo.insert!(%FatUser{
          name: "User #{i}",
          email: "user#{i}@example.com"
        })
      end

      query = from(u in FatUser)

      assert {:ok, result} = TestOffsetPaginator.paginate(query, page_size: 10)
      assert result.metadata.total_pages == 5

      # Last page should have exactly 10 entries
      assert {:ok, last_page} = TestOffsetPaginator.paginate(query, page: 5, page_size: 10)
      assert length(last_page.entries) == 10
      assert last_page.metadata.is_last_page == true
    end
  end

  describe "application configuration" do
    test "uses application config for default_limit and max_limit", _context do
      # Clean up existing users first
      Repo.delete_all(FatUser)

      # Set application config
      Application.put_env(:fat_ecto, FatEcto.Pagination.OffsetPaginator,
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

      # Test default_limit from app config
      {:ok, result} = OffsetPaginator.paginate(query, %{}, Repo, [])
      assert length(result.entries) == 5
      assert result.metadata.page_size == 5

      # Test that explicit options override app config
      {:ok, result} = OffsetPaginator.paginate(query, %{}, Repo, default_limit: 10)
      assert length(result.entries) == 10
      assert result.metadata.page_size == 10

      # Test max_limit from app config
      {:error, error} = OffsetPaginator.paginate(query, %{"limit" => 30}, Repo, [])
      assert error =~ "exceeds maximum allowed value of 25"

      # Test that explicit max_limit overrides app config
      {:ok, result} = OffsetPaginator.paginate(query, %{"limit" => 30}, Repo, max_limit: 50)
      assert length(result.entries) == 20
      assert result.metadata.page_size == 30

      # Clean up
      Application.delete_env(:fat_ecto, FatEcto.Pagination.OffsetPaginator)
    end

    test "macro usage respects application config", _context do
      # Clean up existing users first
      Repo.delete_all(FatUser)

      # Set application config
      Application.put_env(:fat_ecto, FatEcto.Pagination.OffsetPaginator,
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
      defmodule TestAppConfigPaginator do
        use FatEcto.Pagination.OffsetPaginator,
          repo: FatEcto.Repo
      end

      query = from(u in FatUser, order_by: [asc: u.id])

      # Should use default_limit from app config (3)
      {:ok, result} = TestAppConfigPaginator.paginate(query, %{})
      assert length(result.entries) == 3
      assert result.metadata.page_size == 3

      # Should respect max_limit from app config (15)
      {:error, error} = TestAppConfigPaginator.paginate(query, %{"limit" => 20})
      assert error =~ "exceeds maximum allowed value of 15"

      # Clean up
      Application.delete_env(:fat_ecto, FatEcto.Pagination.OffsetPaginator)
    end

    test "repo can be configured via global application config", _context do
      # Clean up existing users first
      Repo.delete_all(FatUser)

      # Set global application config with repo
      Application.put_env(:fat_ecto, FatEcto.Pagination.OffsetPaginator,
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
      defmodule TestGlobalRepoConfigPaginator do
        use FatEcto.Pagination.OffsetPaginator
      end

      query = from(u in FatUser, order_by: [asc: u.id])

      # Should work with repo from global app config
      {:ok, result} = TestGlobalRepoConfigPaginator.paginate(query, %{})
      assert length(result.entries) == 5

      # Clean up
      Application.delete_env(:fat_ecto, FatEcto.Pagination.OffsetPaginator)
    end
  end
end
