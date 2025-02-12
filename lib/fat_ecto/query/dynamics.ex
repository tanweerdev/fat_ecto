defmodule FatEcto.FatQuery.FatDynamics do
  @moduledoc """
  Provides functions to build dynamic `where` conditions for Ecto queries.

  This module is designed to construct complex `where` clauses dynamically using Ecto's `dynamic/2` macro.
  It supports a variety of conditions such as equality, inequality, comparison operators (`>`, `<`, `>=`, `<=`),
  `IN` clauses, `LIKE`/`ILIKE` for string matching, and JSONB operations (`@>`, `&&`).

  ### Key Features:
  - **Dynamic Conditions**: Builds `where` clauses dynamically based on field names, values, and logic types (`:and`/`:or`).
  - **Binding Support**: Supports query bindings for joins or nested queries via the `:binding` option.
  - **JSONB Operations**: Provides functions to work with JSONB fields, such as checking containment or overlap.
  - **String Matching**: Supports `LIKE` and `ILIKE` for substring matching, including case-insensitive searches.
  - **Range Queries**: Allows building conditions for ranges (`BETWEEN`, `IN`, etc.).

  ### Usage:
  Each function in this module constructs a dynamic expression that can be combined with other dynamics or used directly
  in an Ecto query. The functions accept the following common parameters:
  - `key`: The field name (as a string or atom).
  - `value`: The value to compare against (can be a single value, list, or map depending on the function).
  - `opts`: Options to control the behavior, such `:binding` (`:last` for joins).

  ### Example:
    iex> result = #{__MODULE__}.field_is_nil_dynamic(:location)
    iex> inspect(result)
    "dynamic([c], is_nil(c.location))"

  This module is typically used internally by `FatEcto` to construct queries based on user-provided filters.
  """

  import Ecto.Query
  alias FatEcto.FatHelper

  @doc """
  Builds a dynamic query where field is nil.

  Parameters
  - `key`       - Field name.
  - `opts`      - Options for binding.
  Examples
    iex> result = #{__MODULE__}.field_is_nil_dynamic(:location)
    iex> inspect(result)
    "dynamic([c], is_nil(c.location))"
  """
  @spec field_is_nil_dynamic(any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def field_is_nil_dynamic(key, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        is_nil(field(c, ^key))
      )
    else
      dynamic(
        [c],
        is_nil(field(c, ^key))
      )
    end
  end

  @doc """
  Builds dynamic condition for field greater than value.

  Parameters
   - `key`       - Field name.
   - `value`     - Comparison value or field reference.
   - `opts`      - Options for binding
  Examples
    iex> result = #{__MODULE__}.gt_dynamic(:experience_years, 2, [binding: :last])
    iex> inspect(result)
    "dynamic([_, ..., c], c.experience_years > ^2)"
  """
  @spec gt_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def gt_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [_, ..., c],
          field(c, ^key) > ^value
        )
      else
        dynamic(
          [_, ..., c],
          field(c, ^key) > ^value
        )
      end
    else
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [q],
          field(q, ^key) > ^value
        )
      else
        dynamic(
          [q],
          field(q, ^key) > ^value
        )
      end
    end
  end

  @doc """
  Builds dynamic condition for field greater than or equal to value.

  Parameters
   - `key`       - Field name.
   - `value`     - Comparison value or field reference.
   - `opts`      - Options for binding
  Examples
    iex> result = #{__MODULE__}.gte_dynamic(:experience_years, 2, [binding: :last])
    iex> inspect(result)
    "dynamic([_, ..., c], c.experience_years >= ^2)"
  """
  @spec gte_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def gte_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [_, ..., c],
          field(c, ^key) >= ^value
        )
      else
        dynamic(
          [_, ..., c],
          field(c, ^key) >= ^value
        )
      end
    else
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [q],
          field(q, ^key) >= ^value
        )
      else
        dynamic(
          [q],
          field(q, ^key) >= ^value
        )
      end
    end
  end

  @doc """
  Builds dynamic condition for field less than or equal to value.

  Parameters
   - `key`       - Field name.
   - `value`     - Comparison value or field reference.
   - `opts`      - Options for binding
  Examples
    iex> result = #{__MODULE__}.lte_dynamic(:experience_years, 2)
    iex> inspect(result)
    "dynamic([q], q.experience_years <= ^2)"
  """
  @spec lte_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def lte_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [_, ..., c],
          field(c, ^key) <= ^value
        )
      else
        dynamic(
          [c],
          field(c, ^key) <= ^value
        )
      end
    else
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [q],
          field(q, ^key) <= ^value
        )
      else
        dynamic(
          [q],
          field(q, ^key) <= ^value
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where a field is less than a given value.

  ### Parameters

    - `key`       - The field name.
    - `value`     - The value to compare against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.lt_dynamic(:experience_years, 2, [binding: :last])
      iex> inspect(result)
      "dynamic([_, ..., c], c.experience_years < ^2)"
  """
  @spec lt_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def lt_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [_, ..., c],
          field(c, ^key) < ^value
        )
      else
        dynamic(
          [_, ..., c],
          field(c, ^key) < ^value
        )
      end
    else
      if FatHelper.fat_ecto_reserve_field?(value) do
        value = String.replace(value, "$", "", global: false)

        dynamic(
          [q],
          field(q, ^key) < ^value
        )
      else
        dynamic(
          [q],
          field(q, ^key) < ^value
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where a field matches a substring (case-insensitive).

  ### Parameters

    - `key`       - The field name.
    - `value`     - The substring to match.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.ilike_dynamic(:name, "%john%")
      iex> inspect(result)
      "dynamic([q], ilike(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%john%\\\"))"
  """
  @spec ilike_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def ilike_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        ilike(
          fragment("(?)::TEXT", field(c, ^key)),
          ^value
        )
      )
    else
      dynamic(
        [q],
        ilike(
          fragment("(?)::TEXT", field(q, ^key)),
          ^value
        )
      )
    end
  end

  @doc """
  Builds a dynamic query where any element in an array field matches a substring (case-insensitive).

  ### Parameters

    - `key`       - The field name.
    - `value`     - The substring to match.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.array_ilike_dynamic(:tags, "%elixir%")
      iex> inspect(result)
      "dynamic([q], fragment(\\\"EXISTS (SELECT 1 FROM UNNEST(?) as value WHERE value ILIKE ?)\\\", q.tags, ^\\\"%elixir%\\\"))"
  """
  @spec array_ilike_dynamic(any(), any(), nil | maybe_improper_list() | map()) ::
          %Ecto.Query.DynamicExpr{}
  def array_ilike_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        fragment(
          "EXISTS (SELECT 1 FROM UNNEST(?) as value WHERE value ILIKE ?)",
          field(c, ^key),
          ^value
        )
      )
    else
      dynamic(
        [q],
        fragment(
          "EXISTS (SELECT 1 FROM UNNEST(?) as value WHERE value ILIKE ?)",
          field(q, ^key),
          ^value
        )
      )
    end
  end

  @doc """
  Builds a dynamic query where a field matches a substring (case-sensitive).

  ### Parameters

    - `key`       - The field name.
    - `value`     - The substring to match.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.like_dynamic(:name, "%John%")
      iex> inspect(result)
      "dynamic([q], like(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%John%\\\"))"
  """
  @spec like_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def like_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        like(
          fragment("(?)::TEXT", field(c, ^key)),
          ^value
        )
      )
    else
      dynamic(
        [q],
        like(
          fragment("(?)::TEXT", field(q, ^key)),
          ^value
        )
      )
    end
  end

  @doc """
  Builds a dynamic query where a field is equal to a value.

  ### Parameters

    - `key`       - The field name.
    - `value`     - The value to compare against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.eq_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years == ^2)"
  """
  @spec eq_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def eq_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) == ^value
      )
    else
      dynamic(
        [q],
        field(q, ^key) == ^value
      )
    end
  end

  @doc """
  Builds a dynamic query where a field casted to date is equal to a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_eq_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date == ^~D[2025-02-08]))"
  """
  @spec cast_to_date_eq_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def cast_to_date_eq_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., q],
        fragment("?::date", field(q, ^key) == ^value)
      )
    else
      dynamic(
        [q],
        fragment("?::date", field(q, ^key) == ^value)
      )
    end
  end

  @doc """
  Builds a dynamic query where a field casted to date is greater than a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_gt_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date > ^~D[2025-02-08]))"
  """
  @spec cast_to_date_gt_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def cast_to_date_gt_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., q],
        fragment("?::date", field(q, ^key) > ^value)
      )
    else
      dynamic(
        [q],
        fragment("?::date", field(q, ^key) > ^value)
      )
    end
  end

  @doc """
  Builds a dynamic query where a field casted to date is great than or equal to a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_gte_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date >= ^~D[2025-02-08]))"
  """
  @spec cast_to_date_gte_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def cast_to_date_gte_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., q],
        fragment("?::date", field(q, ^key) >= ^value)
      )
    else
      dynamic(
        [q],
        fragment("?::date", field(q, ^key) >= ^value)
      )
    end
  end

  @doc """
  Builds a dynamic query where a field casted to date is less than a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_lt_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date < ^~D[2025-02-08]))"
  """
  @spec cast_to_date_lt_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def cast_to_date_lt_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., q],
        fragment("?::date", field(q, ^key) < ^value)
      )
    else
      dynamic(
        [q],
        fragment("?::date", field(q, ^key) < ^value)
      )
    end
  end

  @doc """
  Builds a dynamic query where a field casted to date is less than or equal to a value.

  ### Parameters

    - `key`       - The field name to cast into date.
    - `value`     - The value to compare against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.cast_to_date_lte_dynamic(:end_date, ~D[2025-02-08])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"?::date\\\", q.end_date <= ^~D[2025-02-08]))"
  """
  @spec cast_to_date_lte_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def cast_to_date_lte_dynamic(key, value, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., q],
        fragment("?::date", field(q, ^key) <= ^value)
      )
    else
      dynamic(
        [q],
        fragment("?::date", field(q, ^key) <= ^value)
      )
    end
  end

  @doc """
  Builds a dynamic query where a field is not equal to a value.

  ### Parameters

    - `key`       - The field name.
    - `value`     - The value to compare against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.not_eq_dynamic(:experience_years, 2)
      iex> inspect(result)
      "dynamic([q], q.experience_years != ^2)"
  """
  @spec not_eq_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def not_eq_dynamic(key, value, opts \\ []) do
    value =
      if is_map(value) do
        %{"$NOT_EQUAL" => v} = value
        v
      else
        value
      end

    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) != ^value
      )
    else
      dynamic(
        [q],
        field(q, ^key) != ^value
      )
    end
  end

  @doc """
  Builds a dynamic query where a field's value is between two provided values.

  ### Parameters

    - `key`       - The field name.
    - `values`    - A list of two values representing the range.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.between_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years > ^2 and q.experience_years < ^5)"
  """
  @spec between_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def between_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) > ^Enum.min(values) and
          field(c, ^key) < ^Enum.max(values)
      )
    else
      dynamic(
        [q],
        field(q, ^key) > ^Enum.min(values) and
          field(q, ^key) < ^Enum.max(values)
      )
    end
  end

  @doc """
  Builds a dynamic query where a field's value is between or equal to two provided values.

  ### Parameters

    - `key`       - The field name.
    - `values`    - A list of two values representing the range.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.between_equal_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years >= ^2 and q.experience_years <= ^5)"
  """
  @spec between_equal_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def between_equal_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) >= ^Enum.min(values) and
          field(c, ^key) <= ^Enum.max(values)
      )
    else
      dynamic(
        [q],
        field(q, ^key) >= ^Enum.min(values) and
          field(q, ^key) <= ^Enum.max(values)
      )
    end
  end

  @doc """
  Builds a dynamic query where a field's value is in a provided list.

  ### Parameters

    - `key`       - The field name.
    - `values`    - A list of values to match against.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.in_dynamic(:experience_years, [2, 5])
      iex> inspect(result)
      "dynamic([q], q.experience_years in ^[2, 5])"
  """
  @spec in_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def in_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        field(c, ^key) in ^values
      )
    else
      dynamic(
        [q],
        field(q, ^key) in ^values
      )
    end
  end

  @doc """
  Builds a dynamic query where a JSONB field contains a specific value.

  ### Parameters

    - `key`       - The JSONB field name.
    - `values`    - The value(s) to check for containment.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.contains_dynamic(:metadata, %{"role" => "admin"})
      iex> inspect(result)
      "dynamic([q], fragment(\\\"? @> ?\\\", q.metadata, ^%{\\\"role\\\" => \\\"admin\\\"}))"
  """
  @spec contains_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def contains_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        fragment("? @> ?", field(c, ^key), ^values)
      )
    else
      dynamic(
        [q],
        fragment("? @> ?", field(q, ^key), ^values)
      )
    end
  end

  @doc """
  Builds a dynamic query where a JSONB field contains any of the provided values.

  ### Parameters

    - `key`       - The JSONB field name.
    - `values`    - The values to check for overlap.
    - `opts`      - Options for binding and logic type (:and/:or).

  ### Examples

      iex> result = #{__MODULE__}.contains_any_dynamic(:tags, ["elixir", "erlang"])
      iex> inspect(result)
      "dynamic([q], fragment(\\\"? && ?\\\", q.tags, ^[\\\"elixir\\\", \\\"erlang\\\"]))"
  """
  @spec contains_any_dynamic(any(), any(), nil | keyword() | map()) :: %Ecto.Query.DynamicExpr{}
  def contains_any_dynamic(key, values, opts \\ []) do
    if opts[:binding] == :last do
      dynamic(
        [_, ..., c],
        fragment("? && ?", field(c, ^key), ^values)
      )
    else
      dynamic(
        [q],
        fragment("? && ?", field(q, ^key), ^values)
      )
    end
  end
end
