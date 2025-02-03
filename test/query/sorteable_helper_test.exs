defmodule FatEcto.FatQuery.SortableHelperTest do
  use FatEcto.ConnCase
  alias FatEcto.FatQuery.SortableHelper

  describe "filter_sortable_fields/2" do
    test "filters fields based on sortable_fields" do
      sort_params = %{"id" => "$asc", "name" => "$desc", "invalid_field" => "$asc"}
      sortable_fields = %{"id" => "$asc", "name" => ["$asc", "$desc"]}

      result = SortableHelper.filter_sortable_fields(sort_params, sortable_fields)

      assert result == %{"id" => "$asc", "name" => "$desc"}
    end

    test "handles wildcard operator (*)" do
      sort_params = %{"id" => "$asc", "name" => "$desc"}
      sortable_fields = %{"id" => "*", "name" => "*"}

      result = SortableHelper.filter_sortable_fields(sort_params, sortable_fields)

      assert result == %{"id" => "$asc", "name" => "$desc"}
    end

    test "ignores invalid operators" do
      sort_params = %{"id" => "$desc", "name" => "$invalid"}
      sortable_fields = %{"id" => "$asc", "name" => ["$asc", "$desc"]}

      result = SortableHelper.filter_sortable_fields(sort_params, sortable_fields)

      assert result == %{}
    end
  end
end
