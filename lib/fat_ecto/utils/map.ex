defmodule FatUtils.Map do
  @moduledoc """
    Provides methods to work with maps and structs cleanup.
  """

  @doc """
    Check if all the keys present in the map and returns true.
  """
  def has_all_keys?(map, keys) do
    Enum.all?(keys, fn key -> Map.has_key?(map, key) end)
  end

  @doc """
    Check if only the given keys are present in map and returns true.
  """
  # TODO: add test cases
  def has_all_keys_exclusive?(map, keys) do
    contain_only_allowed_keys?(map, keys) && has_all_keys?(map, keys)
  end

  @doc """
    Check if only the allowed keys are present in map and returns true.
  """
  # TODO: add test cases
  def contain_only_allowed_keys?(map, keys) do
    Enum.all?(map, fn {k, _v} -> k in keys end)
  end

  @doc """
    Check if keys inside map are equal to specific value.
  """
  def has_all_val_equal_to?(map, keys, equal_to) do
    Enum.all?(keys, fn key -> Map.get(map, key) == equal_to end)
  end

  @doc """
  Check if map contains any of the keys. Reverse to has_all_keys.
  """

  def has_any_of_keys?(map, keys) do
    Enum.any?(keys, fn key -> Map.has_key?(map, key) end)
  end

  @doc """
    Count the number of given keys in a given map.
  """

  def get_keys_count(map, keys) do
    Enum.count(keys, fn key -> Map.has_key?(map, key) end)
  end

  @doc """
   Deep merge two maps.
  """

  def deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  @doc false

  defp deep_resolve(_key, %{} = left, %{} = right) do
    deep_merge(left, right)
  end

  @doc false
  defp deep_resolve(_key, _left, right) do
    right
  end
end
