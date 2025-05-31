defmodule FatEcto.FatV2PaginatorTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatHospital
  alias FatEcto.Sample.V2Pagination

  describe "paginate/2" do
    test "paginates a query with limit and skip" do
      query = from(t in FatHospital)
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
      # TODO: insert some records to test pagination
      # Or whatever records you expect
      assert result.records == []
    end

    test "paginates a query with default limit when not provided" do
      query = from(t in FatHospital)
      params = [skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      # Assuming default limit is 10
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

    test "paginates a query with group_by and count" do
      query = from(t in FatHospital, group_by: t.id)
      params = [limit: 10, skip: 5]

      assert {:ok, %{meta: %{skip: 5, total: 0, limit: 10, pages: 0}, records: []}} =
               V2Pagination.paginate(query, params)
    end

    test "paginates a query with distinct and count" do
      query = from(t in FatHospital, distinct: t.name)
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end

    test "paginates a query with preload and count" do
      query = from(t in FatHospital, preload: [:some_assoc])
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end

    test "paginates a query with order_by and count" do
      query = from(t in FatHospital, order_by: [desc: t.phone])
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end

    test "paginates a query with multiple primary keys and count" do
      query = from(t in FatEcto.FatDoctorPatient)
      params = [limit: 10, skip: 5]

      {:ok, result} = V2Pagination.paginate(query, params)

      assert result.meta.limit == 10
      assert result.meta.skip == 5
    end

    test "paginates a query with no limit or skip" do
      query = from(t in FatHospital)
      params = []

      {:ok, result} = V2Pagination.paginate(query, params)

      # Assuming default limit is 10
      assert result.meta.limit == 10
      assert result.meta.skip == 0
    end
  end
end
