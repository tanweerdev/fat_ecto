defmodule FatEcto.Query.Dynamics.BuildableOverrideEnforcementTest do
  use ExUnit.Case, async: true

  test "modules with overrideable fields must implement override_buildable/3" do
    # This should raise a compilation error because override_buildable/3 is not defined
    # when overrideable fields are present (no default implementation provided)
    assert_raise CompileError, ~r/cannot compile module.*errors have been logged/, fn ->
      defmodule TestModuleRequiresImplementation do
        use FatEcto.Query.Dynamics.Buildable,
          filterable: [
            id: ["$EQUAL", "$NOT_EQUAL"]
          ],
          overrideable: ["name", "phone"]

        # Intentionally NOT implementing override_buildable/3
        # This should fail because no default implementation is provided
      end
    end
  end

  test "modules with overrideable fields work when properly implemented" do
    # This should compile successfully when override_buildable/3 is properly implemented
    defmodule TestModuleProperlyImplemented do
      use FatEcto.Query.Dynamics.Buildable,
        filterable: [
          id: ["$EQUAL", "$NOT_EQUAL"]
        ],
        overrideable: ["name", "phone"]

      import Ecto.Query

      @impl true
      def override_buildable("name", "$ILIKE", value) do
        dynamic([q], ilike(fragment("(?)::TEXT", q.name), ^value))
      end

      def override_buildable("phone", "$ILIKE", value) do
        dynamic([q], ilike(fragment("(?)::TEXT", q.phone), ^value))
      end

      def override_buildable(_field, _operator, _value) do
        nil
      end
    end

    # If we get here, compilation was successful
    assert TestModuleProperlyImplemented.override_buildable("name", "$ILIKE", "test") != nil
  end

  test "modules without overrideable fields get default override_buildable/3 implementation" do
    # This should compile successfully and provide a default override_buildable/3 implementation
    defmodule TestModuleNoOverrideable do
      use FatEcto.Query.Dynamics.Buildable,
        filterable: [
          id: ["$EQUAL", "$NOT_EQUAL"],
          name: ["$ILIKE"]
        ]

      # No overrideable fields, so default implementation should be provided
    end

    # The default implementation should return nil
    assert TestModuleNoOverrideable.override_buildable("any_field", "$EQUAL", "value") == nil
  end
end
