defmodule FatEcto.Utils.Map do
  @moduledoc """
  Provides utility functions for working with maps and structs.

  This module includes functions for checking keys, values, and performing deep merges.
  """

  @doc """
  Checks if all the specified keys are present in the map.

  ## Parameters
  - `map`: The map to check.
  - `keys`: A list of keys to check for.

  ## Examples
      iex> FatEcto.Utils.Map.has_all_keys?(%{a: 1, b: 2}, [:a, :b])
      true
      iex> FatEcto.Utils.Map.has_all_keys?(%{a: 1}, [:a, :b])
      false
  """
  @spec has_all_keys?(map(), list(any())) :: boolean()
  def has_all_keys?(map, keys) do
    Enum.all?(keys, &Map.has_key?(map, &1))
  end

  @doc """
  Checks if the map contains only the specified keys and no others.

  ## Parameters
  - `map`: The map to check.
  - `keys`: A list of allowed keys.

  ## Examples
      iex> FatEcto.Utils.Map.has_all_keys_exclusive?(%{a: 1, b: 2}, [:a, :b])
      true
      iex> FatEcto.Utils.Map.has_all_keys_exclusive?(%{a: 1, c: 3}, [:a, :b])
      false
  """
  @spec has_all_keys_exclusive?(map(), list(any())) :: boolean()
  def has_all_keys_exclusive?(map, keys) do
    contain_only_allowed_keys?(map, keys) && has_all_keys?(map, keys)
  end

  @doc """
  Checks if the map contains only the allowed keys.

  ## Parameters
  - `map`: The map to check.
  - `keys`: A list of allowed keys.

  ## Examples
      iex> FatEcto.Utils.Map.contain_only_allowed_keys?(%{a: 1, b: 2}, [:a, :b])
      true
      iex> FatEcto.Utils.Map.contain_only_allowed_keys?(%{a: 1, c: 3}, [:a, :b])
      false
  """
  @spec contain_only_allowed_keys?(map(), list(any())) :: boolean()
  def contain_only_allowed_keys?(map, keys) do
    Enum.all?(map, fn {k, _v} -> k in keys end)
  end

  @doc """
  Checks if all the specified keys in the map have the given value.

  ## Parameters
  - `map`: The map to check.
  - `keys`: A list of keys to check.
  - `equal_to`: The value to compare against.

  ## Examples
      iex> FatEcto.Utils.Map.has_all_val_equal_to?(%{a: 1, b: 1}, [:a, :b], 1)
      true
      iex> FatEcto.Utils.Map.has_all_val_equal_to?(%{a: 1, b: 2}, [:a, :b], 1)
      false
  """
  @spec has_all_val_equal_to?(map(), list(any()), any()) :: boolean()
  def has_all_val_equal_to?(map, keys, equal_to) do
    Enum.all?(keys, &(Map.get(map, &1) == equal_to))
  end

  @doc """
  Checks if the map contains any of the specified keys.

  ## Parameters
  - `map`: The map to check.
  - `keys`: A list of keys to check for.

  ## Examples
      iex> FatEcto.Utils.Map.has_any_of_keys?(%{a: 1}, [:a, :b])
      true
      iex> FatEcto.Utils.Map.has_any_of_keys?(%{c: 3}, [:a, :b])
      false
  """
  @spec has_any_of_keys?(map(), list(any())) :: boolean()
  def has_any_of_keys?(map, keys) do
    Enum.any?(keys, &Map.has_key?(map, &1))
  end

  @doc """
  Counts the number of specified keys present in the map.

  ## Parameters
  - `map`: The map to check.
  - `keys`: A list of keys to count.

  ## Examples
      iex> FatEcto.Utils.Map.get_keys_count(%{a: 1, b: 2}, [:a, :b, :c])
      2
  """
  @spec get_keys_count(map(), list(any())) :: non_neg_integer()
  def get_keys_count(map, keys) do
    Enum.count(keys, &Map.has_key?(map, &1))
  end

  @doc """
  Deep merges two maps.

  ## Parameters
  - `left`: The first map.
  - `right`: The second map.

  ## Examples
      iex> FatEcto.Utils.Map.deep_merge(%{a: %{b: 1}}, %{a: %{c: 2}})
      %{a: %{b: 1, c: 2}}
  """
  @spec deep_merge(map(), map()) :: map()
  def deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  defp deep_resolve(_key, %{} = left, %{} = right) do
    deep_merge(left, right)
  end

  defp deep_resolve(_key, _left, right) do
    right
  end
end
