defmodule FatEcto.Query.Dynamics.Like do
  @moduledoc """
  Provides dynamic query builders for filtering Ecto queries using `LIKE` and `ILIKE` operators.

  This module is designed to simplify the creation of dynamic queries for Ecto schemas, particularly
  when dealing with pattern matching on text fields or arrays.

  ## Example Usage

      iex> result = #{__MODULE__}.ilike_dynamic(:name, "%john%")
      iex> inspect(result)
      "dynamic([q], ilike(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%john%\\\"))"
  """

  # Import is used by all functions, but not by doctests - suppress warning
  @compile {:no_warn_unused_import, Ecto.Query}
  import Ecto.Query

  @doc """
  Builds a dynamic query where a field matches a substring (case-insensitive).

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The substring to match (e.g., `"%john%"`).

  ### Examples

      iex> result = #{__MODULE__}.ilike_dynamic(:name, "%john%")
      iex> inspect(result)
      "dynamic([q], ilike(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%john%\\\"))"
  """
  @spec ilike_dynamic(atom(), String.t()) :: Ecto.Query.dynamic_expr()
  def ilike_dynamic(key, value) when is_atom(key) and is_binary(value) do
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

    - `key` - The field name as an atom.
    - `value` - The substring to match (e.g., `"%elixir%"`).

  ### Examples

      iex> result = #{__MODULE__}.array_ilike_dynamic(:tags, "%elixir%")
      iex> inspect(result)
      "dynamic([q], fragment(\\\"EXISTS (SELECT 1 FROM UNNEST(?) as value WHERE value ILIKE ?)\\\", q.tags, ^\\\"%elixir%\\\"))"
  """
  @spec array_ilike_dynamic(atom(), String.t()) :: Ecto.Query.dynamic_expr()
  def array_ilike_dynamic(key, value) when is_atom(key) and is_binary(value) do
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

    - `key` - The field name as an atom.
    - `value` - The substring to match (e.g., `"%John%"`).

  ### Examples

      iex> result = #{__MODULE__}.like_dynamic(:name, "%John%")
      iex> inspect(result)
      "dynamic([q], like(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%John%\\\"))"
  """
  @spec like_dynamic(atom(), String.t()) :: Ecto.Query.dynamic_expr()
  def like_dynamic(key, value) when is_atom(key) and is_binary(value) do
    dynamic(
      [q],
      like(
        fragment("(?)::TEXT", field(q, ^key)),
        ^value
      )
    )
  end

  @doc """
  Builds a dynamic query where a field does not match a substring (case-insensitive).

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The substring to exclude (e.g., `"%john%"`).

  ### Examples

      iex> result = #{__MODULE__}.not_ilike_dynamic(:name, "%john%")
      iex> inspect(result)
      "dynamic([q], not ilike(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%john%\\\"))"
  """
  @spec not_ilike_dynamic(atom(), String.t()) :: Ecto.Query.dynamic_expr()
  def not_ilike_dynamic(key, value) when is_atom(key) and is_binary(value) do
    dynamic(
      [q],
      not ilike(
        fragment("(?)::TEXT", field(q, ^key)),
        ^value
      )
    )
  end

  @doc """
  Builds a dynamic query where a field does not match a substring (case-sensitive).

  ### Parameters

    - `key` - The field name as an atom.
    - `value` - The substring to exclude (e.g., `"%John%"`).

  ### Examples

      iex> result = #{__MODULE__}.not_like_dynamic(:name, "%John%")
      iex> inspect(result)
      "dynamic([q], not like(fragment(\\\"(?)::TEXT\\\", q.name), ^\\\"%John%\\\"))"
  """
  @spec not_like_dynamic(atom(), String.t()) :: Ecto.Query.dynamic_expr()
  def not_like_dynamic(key, value) when is_atom(key) and is_binary(value) do
    dynamic(
      [q],
      not like(
        fragment("(?)::TEXT", field(q, ^key)),
        ^value
      )
    )
  end
end
