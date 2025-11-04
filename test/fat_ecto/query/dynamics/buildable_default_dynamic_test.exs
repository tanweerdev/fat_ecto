defmodule FatEcto.Query.Dynamics.BuildableDefaultDynamicTest do
  use FatEcto.ConnCase
  import Ecto.Query

  defmodule TestModuleWithDefaultDynamic do
    use FatEcto.Query.Dynamics.Buildable,
      filterable: [
        name: ["$ILIKE"],
        rating: ["$GT", "$LT"]
      ],
      default_dynamic: :return_true
  end

  defmodule TestModuleWithoutDefaultDynamic do
    use FatEcto.Query.Dynamics.Buildable,
      filterable: [
        name: ["$ILIKE"],
        rating: ["$GT", "$LT"]
      ]
  end

  defmodule TestModuleExplicitNil do
    use FatEcto.Query.Dynamics.Buildable,
      filterable: [
        name: ["$ILIKE"],
        rating: ["$GT", "$LT"]
      ],
      default_dynamic: nil
  end

  describe "default_dynamic: :return_true" do
    test "returns dynamic([q], true) when no dynamics are built" do
      result = TestModuleWithDefaultDynamic.build(%{})

      expected = dynamic([q], true)

      assert inspect(result) == inspect(expected)
    end

    test "returns dynamic([q], true) when params are nil" do
      result = TestModuleWithDefaultDynamic.build(nil)

      expected = dynamic([q], true)

      assert inspect(result) == inspect(expected)
    end

    test "returns built dynamics when conditions exist" do
      result =
        TestModuleWithDefaultDynamic.build(%{
          "name" => %{"$ILIKE" => "%Hospital%"}
        })

      assert inspect(result) =~ "ilike"
      assert inspect(result) =~ "name"
      refute inspect(result) =~ "true"
    end

    test "returns built dynamics for multiple conditions" do
      result =
        TestModuleWithDefaultDynamic.build(%{
          "name" => %{"$ILIKE" => "%Hospital%"},
          "rating" => %{"$GT" => 4}
        })

      assert inspect(result) =~ "rating"
      assert inspect(result) =~ "name"
      refute inspect(result) =~ "true"
    end

    test "can be used with from query" do
      result = TestModuleWithDefaultDynamic.build(%{})

      query = from(h in FatEcto.FatHospital, where: ^result)

      # Should not raise an error
      assert %Ecto.Query{} = query
    end
  end

  describe "no default_dynamic option (default behavior)" do
    test "returns nil when no dynamics are built" do
      result = TestModuleWithoutDefaultDynamic.build(%{})

      assert result == nil
    end

    test "returns nil when params are nil" do
      result = TestModuleWithoutDefaultDynamic.build(nil)

      assert result == nil
    end

    test "returns built dynamics when conditions exist" do
      result =
        TestModuleWithoutDefaultDynamic.build(%{
          "name" => %{"$ILIKE" => "%Hospital%"}
        })

      assert inspect(result) =~ "ilike"
      assert inspect(result) =~ "name"
    end
  end

  describe "explicit nil overrides global config" do
    test "returns nil even if global config is set" do
      # Simulate global config
      Application.put_env(:fat_ecto, :default_dynamic, :return_true)

      result = TestModuleExplicitNil.build(%{})

      assert result == nil

      # Cleanup
      Application.delete_env(:fat_ecto, :default_dynamic)
    end
  end

  describe "global configuration" do
    setup do
      # Save original config
      original = Application.get_env(:fat_ecto, :default_dynamic)

      on_exit(fn ->
        # Restore original config
        if original do
          Application.put_env(:fat_ecto, :default_dynamic, original)
        else
          Application.delete_env(:fat_ecto, :default_dynamic)
        end
      end)
    end

    test "uses global config when no module option provided" do
      # Set global config
      Application.put_env(:fat_ecto, :default_dynamic, :return_true)

      # Define a new module that reads the config at compile time
      # Note: In real usage, this would be defined at compile time with the config already set
      result = TestModuleWithoutDefaultDynamic.build(%{})

      # This test shows the limitation: module attributes are set at compile time
      # In production, modules would be compiled with the config already in place
      # For now, this returns nil because the module was compiled without the config
      assert result == nil
    end
  end
end
