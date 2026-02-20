defmodule FatEcto.Pagination.V2PaginatorTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatHospital
  alias FatEcto.Sample.V2Pagination

  describe "paginate/2 with keyword params" do
    test "paginates a query with limit and skip" do
      query = from(t in FatHospital)
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
      assert result.records == []
    end

    test "paginates a query with default limit when not provided" do
      query = from(t in FatHospital)
      params = [skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end

    test "paginates a query with default skip when not provided" do
      query = from(t in FatHospital)
      params = [limit: 10]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 0
    end

    test "paginates a query with no limit or skip" do
      query = from(t in FatHospital)
      params = []

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 0
    end
  end

  describe "paginate/2 with string-keyed map params" do
    test "accepts integer values" do
      query = from(t in FatHospital)

      {:ok, result} = V2Pagination.paginate(query, %{"limit" => 5, "skip" => 10})

      assert result.meta.limit == 5
      assert result.meta.skip == 10
    end

    test "accepts string values" do
      query = from(t in FatHospital)

      {:ok, result} = V2Pagination.paginate(query, %{"limit" => "5", "skip" => "10"})

      assert result.meta.limit == 5
      assert result.meta.skip == 10
    end

    test "uses defaults for empty map" do
      query = from(t in FatHospital)

      {:ok, result} = V2Pagination.paginate(query, %{})

      assert result.meta.limit == 10
      assert result.meta.skip == 0
    end
  end

  describe "paginate/2 with complex queries" do
    test "handles group_by" do
      query = from(t in FatHospital, group_by: t.id)
      params = [limit: 10, skip: 5]

      assert {:ok, %{meta: %{skip: 5, total: 0, limit: 10, pages: 0}, records: []}} =
               V2Pagination.paginate(query, params)
    end

    test "handles distinct" do
      query = from(t in FatHospital, distinct: t.name)
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end

    test "handles preload" do
      query = from(t in FatHospital, preload: [:some_assoc])
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end

    test "handles order_by" do
      query = from(t in FatHospital, order_by: [desc: t.phone])
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end

    test "handles multiple primary keys" do
      query = from(t in FatEcto.FatDoctorPatient)
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end
  end
end
