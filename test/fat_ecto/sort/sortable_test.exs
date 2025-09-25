defmodule FatEcto.Sort.SortableTest do
  use FatEcto.ConnCase
  import Ecto.Query

  # Test sortable module with standard configuration
  defmodule TestSortable do
    use FatEcto.Sort.Sortable,
      sortable: [
        id: "$ASC",
        name: ["$ASC", "$DESC"],
        # Allows any direction
        email: "*",
        created_at: ["$DESC"]
      ],
      overrideable: ["custom_field", "metadata"]

    @impl true
    def override_sortable("custom_field", "$ASC") do
      {:asc, dynamic([u], fragment("?->>'custom'", u.metadata))}
    end

    def override_sortable("custom_field", "$DESC") do
      {:desc, dynamic([u], fragment("?->>'custom'", u.metadata))}
    end

    def override_sortable("metadata", operator) do
      case operator do
        "$ASC" -> {:asc, dynamic([u], fragment("?->>'sort_key'", u.metadata))}
        "$DESC" -> {:desc, dynamic([u], fragment("?->>'sort_key'", u.metadata))}
        _ -> nil
      end
    end

    def override_sortable(_field, _operator), do: nil
  end

  # Minimal sortable module for testing edge cases
  defmodule MinimalSortable do
    use FatEcto.Sort.Sortable,
      sortable: [id: "$ASC"]
  end

  # Override-only sortable module
  defmodule OverrideOnlySortable do
    use FatEcto.Sort.Sortable,
      overrideable: ["custom_only"]

    @impl true
    def override_sortable("custom_only", "$ASC") do
      {:asc, dynamic([u], u.id)}
    end

    def override_sortable(_field, _operator), do: nil
  end

  describe "build/1 with standard sortable fields" do
    test "builds order for single field with valid operator" do
      sort_params = %{"id" => "$ASC"}

      result = TestSortable.build(sort_params)

      assert is_list(result)
      assert length(result) == 1
      assert match?([{:asc, _}], result)
    end

    test "builds order for multiple fields" do
      sort_params = %{
        "name" => "$DESC",
        "email" => "$ASC"
      }

      result = TestSortable.build(sort_params)

      assert is_list(result)
      assert length(result) == 2
      # Should contain both ASC and DESC orders
      directions = Enum.map(result, fn {dir, _} -> dir end)
      assert :desc in directions
      assert :asc in directions
    end

    test "ignores invalid operators for restricted fields" do
      sort_params = %{
        # id only allows $ASC
        "id" => "$DESC",
        # name allows both, so this should work
        "name" => "$ASC"
      }

      result = TestSortable.build(sort_params)

      # Should only have one result (name), id should be ignored
      assert length(result) == 1
      assert match?([{:asc, _}], result)
    end

    test "handles wildcard fields with any valid operator" do
      sort_params = %{
        # email allows "*" (any valid direction)
        "email" => "$DESC"
      }

      result = TestSortable.build(sort_params)

      assert length(result) == 1
      # Should handle any valid operator for wildcard fields
      assert match?([{:desc, _}], result)
    end

    test "ignores unknown fields" do
      sort_params = %{
        "unknown_field" => "$ASC",
        "name" => "$DESC"
      }

      result = TestSortable.build(sort_params)

      # Should only process the known field
      assert length(result) == 1
      assert match?([{:desc, _}], result)
    end

    test "returns empty list for empty params" do
      result = TestSortable.build(%{})
      assert result == []
    end
  end

  describe "build/1 with overrideable fields" do
    test "processes overrideable fields with custom logic" do
      sort_params = %{"custom_field" => "$ASC"}

      result = TestSortable.build(sort_params)

      assert length(result) == 1
      assert match?([{:asc, %Ecto.Query.DynamicExpr{}}], result)
    end

    test "handles overrideable fields with different operators" do
      sort_params = %{
        "custom_field" => "$ASC",
        "metadata" => "$DESC"
      }

      result = TestSortable.build(sort_params)

      assert length(result) == 2
      directions = Enum.map(result, fn {dir, _} -> dir end)
      assert :asc in directions
      assert :desc in directions
    end

    test "ignores overrideable fields with unsupported operators" do
      sort_params = %{
        # Not handled in override_sortable
        "custom_field" => "$INVALID",
        # This should work
        "metadata" => "$ASC"
      }

      result = TestSortable.build(sort_params)

      # Should only have the valid metadata field
      assert length(result) == 1
      assert match?([{:asc, _}], result)
    end

    test "ignores overrideable fields not in the allowed list" do
      sort_params = %{
        "not_overrideable" => "$ASC",
        "custom_field" => "$DESC"
      }

      result = TestSortable.build(sort_params)

      # Should only process the allowed overrideable field
      assert length(result) == 1
      assert match?([{:desc, _}], result)
    end
  end

  describe "build/1 combining standard and overrideable fields" do
    test "processes both standard and overrideable fields" do
      sort_params = %{
        # standard field
        "name" => "$ASC",
        # overrideable field
        "custom_field" => "$DESC"
      }

      result = TestSortable.build(sort_params)

      assert length(result) == 2
      # Standard fields come first, then override fields
      assert match?([{:asc, _}, {:desc, %Ecto.Query.DynamicExpr{}}], result)
    end

    test "maintains order: standard fields first, then override fields" do
      sort_params = %{
        # overrideable (should be last)
        "custom_field" => "$ASC",
        # standard (should be first)
        "name" => "$DESC",
        # standard (should be second)
        "email" => "$ASC"
      }

      result = TestSortable.build(sort_params)

      assert length(result) == 3

      # Check that all have the right structure and order
      # All expressions in modern Ecto are dynamic, so we check the order by direction
      directions = Enum.map(result, fn {dir, _} -> dir end)

      # Should have the expected directions in order (standard fields first)
      # Note: Order within standard fields depends on map iteration, but override comes last
      assert :asc in directions
      assert :desc in directions

      # The last element should be our custom override
      {last_direction, last_expr} = List.last(result)
      assert last_direction == :asc
      assert match?(%Ecto.Query.DynamicExpr{}, last_expr)
    end
  end

  describe "build/1 input validation" do
    test "handles non-map input" do
      result = TestSortable.build("not a map")
      assert result == []
    end

    test "handles nil input" do
      result = TestSortable.build(nil)
      assert result == []
    end

    test "handles atom keys in map" do
      sort_params = %{name: "$ASC", email: "$DESC"}

      result = TestSortable.build(sort_params)

      # Should handle atom keys by converting them or ignoring them
      # The actual behavior depends on implementation
      assert is_list(result)
    end
  end

  describe "minimal sortable module" do
    test "works with minimal configuration" do
      sort_params = %{"id" => "$ASC"}

      result = MinimalSortable.build(sort_params)

      assert length(result) == 1
      assert match?([{:asc, _}], result)
    end

    test "ignores fields not in sortable list" do
      sort_params = %{"unknown" => "$ASC"}

      result = MinimalSortable.build(sort_params)

      assert result == []
    end
  end

  describe "override-only sortable module" do
    test "works with only overrideable fields" do
      sort_params = %{"custom_only" => "$ASC"}

      result = OverrideOnlySortable.build(sort_params)

      assert length(result) == 1
      assert match?([{:asc, _}], result)
    end

    test "ignores standard sort operators for override-only module" do
      # Not in overrideable list
      sort_params = %{"id" => "$ASC"}

      result = OverrideOnlySortable.build(sort_params)

      assert result == []
    end
  end

  describe "override_sortable/2 default implementation" do
    defmodule NoOverrideSortable do
      use FatEcto.Sort.Sortable,
        sortable: [id: "$ASC"]

      # Uses default override_sortable implementation (returns nil)
    end

    test "default implementation returns nil" do
      result = NoOverrideSortable.override_sortable("anything", "$ASC")
      assert result == nil
    end
  end

  describe "__using__ macro validation" do
    test "raises error when both sortable and overrideable are empty" do
      assert_raise ArgumentError, ~r/At least one of/, fn ->
        defmodule EmptyConfig do
          use FatEcto.Sort.Sortable
        end
      end
    end

    test "raises error when both sortable and overrideable are empty lists" do
      assert_raise ArgumentError, ~r/At least one of/, fn ->
        defmodule EmptyLists do
          use FatEcto.Sort.Sortable,
            sortable: [],
            overrideable: []
        end
      end
    end

    test "validates sortable format" do
      assert_raise ArgumentError, ~r/Please send/, fn ->
        defmodule InvalidSortable do
          use FatEcto.Sort.Sortable,
            sortable: "invalid"
        end
      end
    end

    test "validates overrideable format" do
      assert_raise ArgumentError, ~r/Please send/, fn ->
        defmodule InvalidOverrideable do
          use FatEcto.Sort.Sortable,
            sortable: [id: "$ASC"],
            overrideable: "invalid"
        end
      end
    end

    test "allows valid configurations" do
      # These should not raise errors
      defmodule ValidConfig1 do
        use FatEcto.Sort.Sortable,
          sortable: [id: "$ASC"]
      end

      defmodule ValidConfig2 do
        use FatEcto.Sort.Sortable,
          overrideable: ["custom"]

        @impl true
        def override_sortable(_field, _operator), do: nil
      end

      defmodule ValidConfig3 do
        use FatEcto.Sort.Sortable,
          sortable: [id: "$ASC"],
          overrideable: ["custom"]

        @impl true
        def override_sortable(_field, _operator), do: nil
      end

      # If we get here without exceptions, the test passes
      assert true
    end
  end

  describe "integration with Ecto queries" do
    test "generated order expressions work with Ecto queries" do
      # Create a simple test to verify the generated expressions are valid
      sort_params = %{"name" => "$ASC"}
      order_expressions = TestSortable.build(sort_params)

      # Should be able to use in a query without errors
      query = from(u in "users", order_by: ^order_expressions)

      assert %Ecto.Query{} = query
      assert length(query.order_bys) == 1
    end

    test "custom dynamic expressions work with Ecto queries" do
      sort_params = %{"custom_field" => "$DESC"}
      order_expressions = TestSortable.build(sort_params)

      # Should be able to use custom dynamic expressions in queries
      query = from(u in "users", order_by: ^order_expressions)

      assert %Ecto.Query{} = query
      assert length(query.order_bys) == 1
    end
  end
end
