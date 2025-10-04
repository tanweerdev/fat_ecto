defmodule FatEcto.Query.BuildableOverrideEnforcementTest do
  use ExUnit.Case, async: true

  test "modules with overrideable fields must implement override_buildable/4" do
    # This should raise a compilation error because override_buildable/4 is not defined
    # when overrideable fields are present (no default implementation provided)
    assert_raise CompileError, ~r/cannot compile module.*errors have been logged/, fn ->
      defmodule TestQueryModuleRequiresImplementation do
        use FatEcto.Query.Buildable,
          filterable: [
            id: ["$EQUAL", "$NOT_EQUAL"]
          ],
          overrideable: ["name", "phone"]

        # Intentionally NOT implementing override_buildable/4
        # This should fail because no default implementation is provided
      end
    end
  end

  test "modules with overrideable fields work when properly implemented" do
    # This should compile successfully when override_buildable/4 is properly implemented
    defmodule TestQueryModuleProperlyImplemented do
      use FatEcto.Query.Buildable,
        filterable: [
          id: ["$EQUAL", "$NOT_EQUAL"]
        ],
        overrideable: ["name", "phone"]

      import Ecto.Query

      @impl true
      def override_buildable(query, "name", "$ILIKE", value) do
        from(q in query, where: ilike(fragment("(?)::TEXT", q.name), ^value))
      end

      def override_buildable(query, "phone", "$ILIKE", value) do
        from(q in query, where: ilike(fragment("(?)::TEXT", q.phone), ^value))
      end

      def override_buildable(query, _field, _operator, _value) do
        query
      end
    end

    # If we get here, compilation was successful
    # Test that the implementation works
    import Ecto.Query
    query = from(u in "users", select: u)
    result = TestQueryModuleProperlyImplemented.override_buildable(query, "name", "$ILIKE", "test")

    # The result should be a query with a where clause added
    assert %Ecto.Query{} = result
    # Should be different from original query
    assert result != query
  end

  test "modules without overrideable fields get default override_buildable/4 implementation" do
    # This should compile successfully and provide a default override_buildable/4 implementation
    defmodule TestQueryModuleNoOverrideable do
      use FatEcto.Query.Buildable,
        filterable: [
          id: ["$EQUAL", "$NOT_EQUAL"],
          name: ["$ILIKE"]
        ]

      # No overrideable fields, so default implementation should be provided
    end

    # The default implementation should return the query unchanged
    import Ecto.Query
    query = from(u in "users", select: u)
    result = TestQueryModuleNoOverrideable.override_buildable(query, "any_field", "$EQUAL", "value")

    # Should be unchanged
    assert result == query
  end
end
