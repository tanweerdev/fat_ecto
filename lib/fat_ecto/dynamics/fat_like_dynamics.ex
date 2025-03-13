defmodule FatEcto.Dynamics.FatLikeDynamics do
  import Ecto.Query

  @doc """
  Builds a dynamic query where a field matches a substring (case-insensitive).

  ### Parameters

    - `key`       - The field name.
    - `value`     - The substring to match.

  ### Examples

      iex> result = #{__MODULE__}.ilike_dynamic(:name, "%john%")
      iex> inspect(result)
      "dynamic([q], ilike(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%john%\\\"))"
  """
  @spec ilike_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def ilike_dynamic(key, value) do
    dynamic(
      [q],
      ilike(
        fragment("(?)::TEXT", field(q, ^key)),
        ^value
      )
    )
  end

  @doc """
  Builds a dynamic query where any element in an array field matches a substring (case-insensitive).

  ### Parameters

    - `key`       - The field name.
    - `value`     - The substring to match.

  ### Examples

      iex> result = #{__MODULE__}.array_ilike_dynamic(:tags, "%elixir%")
      iex> inspect(result)
      "dynamic([q], fragment(\\\"EXISTS (SELECT 1 FROM UNNEST(?) as value WHERE value ILIKE ?)\\\", q.tags, ^\\\"%elixir%\\\"))"
  """
  @spec array_ilike_dynamic(any(), any()) ::
          Ecto.Query.dynamic_expr()
  def array_ilike_dynamic(key, value) do
    dynamic(
      [q],
      fragment(
        "EXISTS (SELECT 1 FROM UNNEST(?) as value WHERE value ILIKE ?)",
        field(q, ^key),
        ^value
      )
    )
  end

  @doc """
  Builds a dynamic query where a field matches a substring (case-sensitive).

  ### Parameters

    - `key`       - The field name.
    - `value`     - The substring to match.

  ### Examples

      iex> result = #{__MODULE__}.like_dynamic(:name, "%John%")
      iex> inspect(result)
      "dynamic([q], like(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%John%\\\"))"
  """
  @spec like_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def like_dynamic(key, value) do
    dynamic(
      [q],
      like(
        fragment("(?)::TEXT", field(q, ^key)),
        ^value
      )
    )
  end

  @doc """

  Builds a dynamic query where field not matches the value substring.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
  """

  @spec not_ilike_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_ilike_dynamic(key, value) do
    dynamic(
      [q],
      not ilike(
        fragment("(?)::TEXT", field(q, ^key)),
        ^value
      )
    )
  end

  @doc """
  Builds a dynamic query where field not matches the value substring.
  ### Parameters

     - `key`       - Field name.
     - `value`     - Value of the field.
  """

  @spec not_like_dynamic(any(), any()) :: Ecto.Query.dynamic_expr()
  def not_like_dynamic(key, value) do
    dynamic(
      [q],
      not like(
        fragment("(?)::TEXT", field(q, ^key)),
        ^value
      )
    )
  end
end
