defmodule FatEcto.Sort.HelperTest do
  use FatEcto.ConnCase
  alias FatEcto.Sort.Helper

  describe "filter_sortable_fields/2" do
    test "filters fields based on sortable_fields" do
      sort_params = %{"id" => "$ASC", "name" => "$DESC", "invalid_field" => "$ASC"}
      sortable_fields = %{"id" => "$ASC", "name" => ["$ASC", "$DESC"]}

      result = Helper.filter_sortable_fields(sort_params, sortable_fields)

      assert result == %{"id" => "$ASC", "name" => "$DESC"}
    end

    test "handles wildcard operator (*)" do
      sort_params = %{"id" => "$ASC", "name" => "$DESC"}
      sortable_fields = %{"id" => "*", "name" => "*"}

      result = Helper.filter_sortable_fields(sort_params, sortable_fields)

      assert result == %{"id" => "$ASC", "name" => "$DESC"}
    end

    test "ignores invalid operators" do
      sort_params = %{"id" => "$DESC", "name" => "$INvalid"}
      sortable_fields = %{"id" => "$ASC", "name" => ["$ASC", "$DESC"]}

      result = Helper.filter_sortable_fields(sort_params, sortable_fields)

      assert result == %{}
    end
  end
end
