defmodule FatEcto.Pagination.PaginatorNewTest do
  use FatEcto.ConnCase
  import Ecto.Query

  alias FatEcto.FatHospital

  # Create a test paginator module
  defmodule TestPaginator do
    use FatEcto.Pagination.Paginator,
      repo: FatEcto.Repo,
      default_limit: 10,
      max_limit: 50
  end

  describe "paginate/2" do
    test "returns pagination structure with default values" do
      query = from(h in FatHospital)
      params = []

      result = TestPaginator.paginate(query, params)

      assert %{
               data_query: data_query,
               count_query: count_query,
               limit: limit,
               skip: skip
             } = result

      # default_limit
      assert limit == 10
      # default skip
      assert skip == 0
      assert %Ecto.Query{} = data_query
      assert %Ecto.Query{} = count_query
    end

    test "uses provided limit and skip values" do
      query = from(h in FatHospital)
      params = [limit: 20, skip: 30]

      result = TestPaginator.paginate(query, params)

      assert result.limit == 20
      assert result.skip == 30
    end

    test "respects max_limit configuration" do
      query = from(h in FatHospital)
      # exceeds max_limit of 50
      params = [limit: 100]

      result = TestPaginator.paginate(query, params)

      # should be capped at max_limit
      assert result.limit == 50
    end

    test "data_query includes limit and offset" do
      query = from(h in FatHospital)
      params = [limit: 5, skip: 10]

      result = TestPaginator.paginate(query, params)

      # Check that the data query has limit and offset set
      assert result.data_query.limit != nil
      assert result.data_query.offset != nil
      # Check for the specific limit and offset expression types
      assert match?(%Ecto.Query.LimitExpr{}, result.data_query.limit)
      assert match?(%Ecto.Query.QueryExpr{}, result.data_query.offset)
    end

    test "count_query excludes order_by and preload" do
      query = from(h in FatHospital, order_by: h.name, preload: [:doctors])
      params = [limit: 10, skip: 0]

      result = TestPaginator.paginate(query, params)

      # Count query should exclude order_by and preload
      assert result.count_query.order_bys == []
      assert result.count_query.preloads == []
      assert result.count_query.distinct.expr == true
    end
  end

  describe "paginator/2" do
    setup do
      # Create some test data
      hospital1 = insert(:hospital, name: "Test Hospital 1")
      hospital2 = insert(:hospital, name: "Test Hospital 2")
      hospital3 = insert(:hospital, name: "Test Hospital 3")

      {:ok, hospitals: [hospital1, hospital2, hospital3]}
    end

    test "returns paginated query with metadata", %{hospitals: _hospitals} do
      query = from(h in FatHospital)
      params = %{"limit" => "2", "skip" => "0"}

      {data_query, meta} = TestPaginator.paginator(query, params)

      assert %Ecto.Query{} = data_query

      assert %{
               skip: 0,
               limit: 2,
               total_records: total_records,
               pages: pages
             } = meta

      assert is_integer(total_records)
      # We inserted at least 3 records
      assert total_records >= 3
      assert is_integer(pages)
      # With limit 2 and 3+ records, should have 2+ pages
      assert pages >= 2
    end

    test "calculates pages correctly", %{hospitals: _hospitals} do
      query = from(h in FatHospital)
      params = %{"limit" => "2", "skip" => "0"}

      {_data_query, meta} = TestPaginator.paginator(query, params)

      # With 3 records and limit 2, should have 2 pages
      expected_pages = trunc(Float.ceil(meta.total_records / 2))
      assert meta.pages == expected_pages
    end

    test "uses default values when params are missing" do
      query = from(h in FatHospital)
      params = %{}

      {_data_query, meta} = TestPaginator.paginator(query, params)

      assert meta.skip == 0
      # default_limit
      assert meta.limit == 10
    end

    test "handles string parameters correctly" do
      query = from(h in FatHospital)
      params = %{"limit" => "5", "skip" => "10"}

      {_data_query, meta} = TestPaginator.paginator(query, params)

      assert meta.skip == 10
      assert meta.limit == 5
    end
  end

  describe "paginate_get_records/2" do
    setup do
      # Create test data
      hospital1 = insert(:hospital, name: "Hospital A")
      hospital2 = insert(:hospital, name: "Hospital B")
      hospital3 = insert(:hospital, name: "Hospital C")

      {:ok, hospitals: [hospital1, hospital2, hospital3]}
    end

    test "returns actual records with metadata", %{hospitals: hospitals} do
      query = from(h in FatHospital, order_by: h.name)
      params = %{"limit" => "2", "skip" => "0"}

      {records, meta} = TestPaginator.paginate_get_records(query, params)

      assert is_list(records)
      # Should respect limit
      assert length(records) <= 2
      assert Enum.all?(records, &match?(%FatHospital{}, &1))

      assert %{
               skip: 0,
               limit: 2,
               total_records: total_records,
               pages: _pages
             } = meta

      assert total_records >= length(hospitals)
    end

    test "paginates correctly with offset", %{hospitals: _hospitals} do
      query = from(h in FatHospital, order_by: h.id)

      # Get first page
      {records_page1, _meta} = TestPaginator.paginate_get_records(query, %{"limit" => "2", "skip" => "0"})

      # Get second page
      {records_page2, _meta} = TestPaginator.paginate_get_records(query, %{"limit" => "2", "skip" => "2"})

      # Records should be different
      refute Enum.any?(records_page1, fn r1 ->
               Enum.any?(records_page2, fn r2 -> r1.id == r2.id end)
             end)
    end
  end

  describe "count_records/1" do
    setup do
      # Create test data
      insert(:hospital, name: "Hospital 1")
      insert(:hospital, name: "Hospital 2")
      insert(:hospital, name: "Hospital 3")
      :ok
    end

    test "counts records correctly for simple query" do
      query = from(h in FatHospital)
      count_query = TestPaginator.count_query(query)

      count = TestPaginator.count_records(count_query)

      assert is_integer(count)
      # We inserted at least 3 records
      assert count >= 3
    end

    test "counts records with where conditions" do
      insert(:hospital, name: "Special Hospital")

      query = from(h in FatHospital, where: ilike(h.name, "%Special%"))
      count_query = TestPaginator.count_query(query)

      count = TestPaginator.count_records(count_query)

      # Should find our special hospital
      assert count >= 1
    end
  end

  describe "data_query/3" do
    test "applies limit and offset correctly" do
      query = from(h in FatHospital)

      result_query = TestPaginator.data_query(query, 10, 5)

      # Check that limit and offset are applied (they become parameterized expressions)
      assert result_query.limit != nil
      assert result_query.offset != nil
      assert match?(%Ecto.Query.LimitExpr{}, result_query.limit)
      assert match?(%Ecto.Query.QueryExpr{}, result_query.offset)
    end

    test "preserves original query structure" do
      original_query = from(h in FatHospital, where: h.name == "Test", order_by: h.id)

      result_query = TestPaginator.data_query(original_query, 0, 10)

      # Should preserve where and order_by clauses
      assert length(result_query.wheres) == length(original_query.wheres)
      assert length(result_query.order_bys) == length(original_query.order_bys)
    end
  end

  describe "count_query/1" do
    test "removes order_by and preload from query" do
      query =
        from(h in FatHospital,
          order_by: [desc: h.name],
          preload: [:doctors]
        )

      count_query = TestPaginator.count_query(query)

      assert count_query.order_bys == []
      assert count_query.preloads == []
    end

    test "sets distinct to true" do
      query = from(h in FatHospital)

      count_query = TestPaginator.count_query(query)

      assert count_query.distinct.expr == true
    end

    test "preserves where clauses" do
      query = from(h in FatHospital, where: h.name == "Test")

      count_query = TestPaginator.count_query(query)

      assert length(count_query.wheres) == length(query.wheres)
    end
  end

  describe "aggregate/1" do
    test "handles query without distinct" do
      query = from(h in FatHospital)

      result = TestPaginator.aggregate(query)

      assert %Ecto.Query{} = result
      # The aggregate function should return a valid query (behavior may vary based on primary keys)
      # We just check it returns a query and is callable
    end

    test "handles query with group_by" do
      query = from(h in FatHospital, group_by: h.name)

      result = TestPaginator.aggregate(query)

      assert %Ecto.Query{} = result
      # For group_by queries, it should still be a valid query
      # Implementation details may vary, but should return processable query
    end

    test "handles query with different primary key structures" do
      query = from(h in FatHospital)

      # Test that it can handle the query regardless of primary key setup
      result = TestPaginator.aggregate(query)

      assert %Ecto.Query{} = result
      # Should be able to process the result
    end
  end

  describe "__using__ macro validation" do
    test "validates repo is provided at compile time" do
      # This test ensures the repo option is required
      # The actual validation happens at compile time via @after_compile
      assert TestPaginator.repo_option() == FatEcto.Repo
    end

    test "uses default configuration values" do
      defmodule MinimalPaginator do
        use FatEcto.Pagination.Paginator, repo: FatEcto.Repo
      end

      query = from(h in FatHospital)
      result = MinimalPaginator.paginate(query, [])

      # default_limit
      assert result.limit == 10
      # default skip
      assert result.skip == 0
    end
  end
end
