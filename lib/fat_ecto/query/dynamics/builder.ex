defmodule FatEcto.Query.Dynamics.Builder do
  @moduledoc """
  Builds Ecto dynamic expressions from a structured query map.
  Used by FatDynamicsBuildable for dynamic-only use cases.
  """

  alias FatEcto.Query.Dynamics.Helper, as: DynamicsHelper
  alias FatEcto.Query.OperatorApplier

  @doc """
  Builds an Ecto dynamic query from a JSON-like structure.

  ## Parameters

  - `query_map` - A map of field => value or field => %{operator => value}
  - `override_callback` - Optional callback for overrideable fields
  - `overrideable_fields` - List of fields that use the override callback
  - `join_filters` - Optional map of field_name => binding_atom for join filter fields

  ## Join Filters

  When `join_filters` is provided, any field in that map will use `JoinOperatorApplier`
  to generate dynamics with named bindings instead of the default table binding.

      # Example join_filters:
      %{"subject_id" => :classifications, "grade_id" => :classifications}

      # This causes subject_id filters to generate:
      dynamic([classifications: joined], joined.subject_id == ^value)

  ## Examples

      iex> import Ecto.Query
      ...> query = FatEcto.Query.Dynamics.Builder.build(%{
      ...>   "$OR" => [
      ...>     %{"name" => "John"},
      ...>     %{"phone" => nil},
      ...>     %{"age" => %{"$GT" => 30}}
      ...>   ]
      ...> })
      iex> inspect(query)
      "dynamic([q], q.name == ^\\\"John\\\" or is_nil(q.phone) or q.age > ^30)"
  """
  @spec build(map(), function() | nil, list() | nil, map() | nil) :: Ecto.Query.dynamic_expr()
  def build(query_map, override_callback \\ nil, overrideable_fields \\ nil, join_filters \\ nil)

  def build(query_map, override_callback, overrideable_fields, join_filters) when is_map(query_map) do
    Enum.reduce(query_map, nil, fn {key, value}, dynamic ->
      case key do
        "$OR" ->
          build_or_dynamic(value, dynamic, override_callback, overrideable_fields, join_filters)

        "$AND" ->
          build_and_dynamic(value, dynamic, override_callback, overrideable_fields, join_filters)

        _ ->
          build_field_dynamic(key, value, dynamic, override_callback, overrideable_fields, join_filters)
      end
    end)
  end

  def build(_query_map, _override_callback, _overrideable_fields, _join_filters), do: nil

  # Dynamic-specific implementations
  # Handles "$OR" conditions
  defp build_or_dynamic(conditions, dynamic, override_callback, overrideable_fields, join_filters)
       when is_map(conditions) do
    # Handle direct map (e.g., "$OR" => %{"rating" => %{"$GT" => 18}})
    or_dynamic =
      Enum.reduce(conditions, nil, fn {field, value}, acc ->
        field_dynamic =
          build_field_dynamic(field, value, nil, override_callback, overrideable_fields, join_filters)

        DynamicsHelper.merge_dynamics(acc, field_dynamic, :or)
      end)

    DynamicsHelper.merge_dynamics(dynamic, or_dynamic, :and)
  end

  defp build_or_dynamic(conditions, dynamic, override_callback, overrideable_fields, join_filters) do
    # Handle array (e.g., "$OR" => [%{"rating" => %{"$GT" => 18}}])
    conditions
    |> ensure_list()
    |> Enum.reduce(nil, fn condition, acc ->
      condition_dynamic = build(condition, override_callback, overrideable_fields, join_filters)
      DynamicsHelper.merge_dynamics(acc, condition_dynamic, :or)
    end)
    |> DynamicsHelper.merge_dynamics(dynamic, :and)
  end

  # Handles "$AND" conditions
  defp build_and_dynamic(conditions, dynamic, override_callback, overrideable_fields, join_filters) do
    conditions
    |> ensure_list()
    |> Enum.reduce(nil, fn condition, acc ->
      condition_dynamic = build(condition, override_callback, overrideable_fields, join_filters)
      DynamicsHelper.merge_dynamics(acc, condition_dynamic, :and)
    end)
    |> DynamicsHelper.merge_dynamics(dynamic, :and)
  end

  # Handles individual field conditions
  defp build_field_dynamic(
         field,
         conditions,
         dynamic,
         override_callback,
         overrideable_fields,
         join_filters
       )
       when is_map(conditions) do
    field_dynamic =
      Enum.reduce(conditions, nil, fn {operator, value}, acc ->
        normalized_operator = String.upcase(operator)

        dynamic =
          cond do
            # 1. Check if it's a join filter field - use OperatorApplier with binding
            join_filter_field?(field, join_filters) ->
              binding = get_join_binding(field, join_filters)
              OperatorApplier.apply_operator(normalized_operator, field, value, binding)

            # 2. Check if it should use override callback
            should_override?(field, overrideable_fields) && override_callback ->
              override_callback.(field, normalized_operator, value)

            # 3. Default: use standard OperatorApplier (no binding)
            true ->
              OperatorApplier.apply_operator(normalized_operator, field, value)
          end

        DynamicsHelper.merge_dynamics(acc, dynamic, :and)
      end)

    DynamicsHelper.merge_dynamics(dynamic, field_dynamic, :and)
  end

  # Handles direct field comparisons (e.g., "field" => "value" or "field" => nil)
  defp build_field_dynamic(
         field,
         value,
         dynamic,
         override_callback,
         overrideable_fields,
         join_filters
       ) do
    operator = if is_nil(value), do: "$NULL", else: "$EQUAL"

    field_dynamic =
      cond do
        # 1. Check if it's a join filter field - use OperatorApplier with binding
        join_filter_field?(field, join_filters) ->
          binding = get_join_binding(field, join_filters)
          OperatorApplier.apply_operator(operator, field, value, binding)

        # 2. Check if it should use override callback
        should_override?(field, overrideable_fields) && override_callback ->
          override_callback.(field, operator, value) ||
            OperatorApplier.apply_operator(operator, field, value)

        # 3. Default: use standard OperatorApplier (no binding)
        true ->
          OperatorApplier.apply_operator(operator, field, value)
      end

    DynamicsHelper.merge_dynamics(dynamic, field_dynamic, :and)
  end

  # Common helpers
  defp should_override?(field, overrideable_fields) do
    case overrideable_fields do
      nil -> true
      fields when is_list(fields) -> field in fields
      fields when is_map(fields) -> Map.has_key?(fields, field)
      _ -> true
    end
  end

  # Checks if a field is a join filter field
  defp join_filter_field?(_field, nil), do: false
  defp join_filter_field?(_field, join_filters) when join_filters == %{}, do: false

  defp join_filter_field?(field, join_filters) when is_map(join_filters) do
    Map.has_key?(join_filters, field)
  end

  # Gets the binding for a join filter field
  defp get_join_binding(field, join_filters) when is_map(join_filters) do
    Map.get(join_filters, field)
  end

  # Ensures the input is a list (converts maps to a list of one element)
  defp ensure_list(input) when is_map(input), do: [input]
  defp ensure_list(input) when is_list(input), do: input
  defp ensure_list(_), do: []
end
