defmodule FatEcto.Pagination.PaginatorTest do
  use FatEcto.ConnCase
  import Ecto.Query
  alias FatEcto.FatHospital
  alias FatEcto.Sample.Pagination

  describe "paginate/2" do
    test "paginates a query with limit and skip" do
      query = from(t in FatHospital)
      params = [limit: 10, skip: 5]

      result = Pagination.paginate(query, params)

      assert result.limit == 10
      assert result.skip == 5
      assert inspect(result.data_query) == inspect(from(t in FatHospital, limit: ^10, offset: ^5))
      assert inspect(result.count_query) == inspect(from(t in FatHospital, distinct: true))
    end

    test "paginates a query with default limit when not provided" do
      query = from(t in FatHospital)
      params = [skip: 5]

      result = Pagination.paginate(query, params)

      # Assuming default limit is 10
      assert result.limit == 10
      assert result.skip == 5
      assert inspect(result.data_query) == inspect(from(t in FatHospital, limit: ^10, offset: ^5))
      assert inspect(result.count_query) == inspect(from(t in FatHospital, distinct: true))
    end

    test "paginates a query with default skip when not provided" do
      query = from(t in FatHospital)
      params = [limit: 10]

      result = Pagination.paginate(query, params)

      assert result.limit == 10
      assert result.skip == 0
      assert inspect(result.data_query) == inspect(from(t in FatHospital, limit: ^10, offset: ^0))
      assert inspect(result.count_query) == inspect(from(t in FatHospital, distinct: true))
    end

    test "paginates a query with group_by and count" do
      query = from(t in FatHospital, group_by: t.name)
      params = [limit: 10, skip: 5]

      result = Pagination.paginate(query, params)

      assert result.limit == 10
      assert result.skip == 5

      assert inspect(result.data_query) ==
               inspect(from(t in FatHospital, group_by: t.name, limit: ^10, offset: ^5))

      assert inspect(result.count_query) == inspect(from(t in FatHospital, group_by: t.name, distinct: true))
    end

    test "paginates a query with distinct and count" do
      query = from(t in FatHospital, distinct: t.name)
      params = [limit: 10, skip: 5]

      result = Pagination.paginate(query, params)

      assert result.limit == 10
      assert result.skip == 5

      assert inspect(result.data_query) ==
               inspect(from(t in FatHospital, distinct: t.name, limit: ^10, offset: ^5))

      assert inspect(result.count_query) ==
               inspect(
                 from(f0 in subquery(from(f0 in FatEcto.FatHospital, distinct: [asc: f0.name])),
                   distinct: true,
                   select: count("*")
                 )
               )
    end

    test "paginates a query with preload and count" do
      query = from(t in FatHospital, preload: [:some_assoc])
      params = [limit: 10, skip: 5]

      result = Pagination.paginate(query, params)

      assert result.limit == 10
      assert result.skip == 5

      assert inspect(result.data_query) ==
               inspect(from(t in FatHospital, preload: [:some_assoc], limit: ^10, offset: ^5))

      assert inspect(result.count_query) == inspect(from(t in FatHospital, distinct: true))
    end

    test "paginates a query with order_by and count" do
      query = from(t in FatHospital, order_by: [desc: t.age])
      params = [limit: 10, skip: 5]

      result = Pagination.paginate(query, params)

      assert result.limit == 10
      assert result.skip == 5

      assert inspect(result.data_query) ==
               inspect(from(t in FatHospital, order_by: [desc: t.age], limit: ^10, offset: ^5))

      assert inspect(result.count_query) == inspect(from(t in FatHospital, distinct: true))
    end

    test "paginates a query with multiple primary keys and count" do
      query = from(t in FatHospital)
      params = [limit: 10, skip: 5]

      # Mock primary keys for testing
      defmodule FatHospitalWithPrimaryKeys do
        use Ecto.Schema

        schema "test_schema_with_primary_keys" do
          field(:id1, :integer, primary_key: true)
          field(:id2, :integer, primary_key: true)
        end
      end

      query_with_primary_keys = from(t in FatHospitalWithPrimaryKeys)
      result = Pagination.paginate(query_with_primary_keys, params)

      assert result.limit == 10
      assert result.skip == 5

      assert inspect(result.data_query) ==
               inspect(from(t in FatHospitalWithPrimaryKeys, limit: ^10, offset: ^5))

      assert inspect(result.count_query) ==
               inspect(
                 from(f0 in FatEcto.Pagination.PaginatorTest.FatHospitalWithPrimaryKeys,
                   distinct: true,
                   select: fragment("COUNT(DISTINCT ROW(?, ?, ?))::INT", f0.id, f0.id1, f0.id2)
                 )
               )
    end

    test "paginates a query with no limit or skip" do
      query = from(t in FatHospital)
      params = []

      result = Pagination.paginate(query, params)

      # Assuming default limit is 10
      assert result.limit == 10
      assert result.skip == 0
      assert inspect(result.data_query) == inspect(from(t in FatHospital, limit: ^10, offset: ^0))
      assert inspect(result.count_query) == inspect(from(t in FatHospital, distinct: true))
    end
  end
end
