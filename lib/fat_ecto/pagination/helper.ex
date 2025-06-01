defmodule FatEcto.Pagination.Helper do
  @moduledoc """
  Provides utility functions for FatEcto, including handling pagination limits, skip values,
  dynamic binding, and preloading associations.
  """

  require Ecto.Query
  alias FatEcto.SharedHelper

  @min_limit 0
  @min_skip 0
  @default_skip 0

  @doc """
  Returns the maximum and default limit values based on the provided options.

  ## Parameters
  - `options`: A keyword list or map containing `max_limit` and `default_limit`.

  ## Examples
      iex> FatEcto.Pagination.Helper.get_limit_bounds(max_limit: 50, default_limit: 10)
      {50, 10}
  """
  @spec get_limit_bounds(nil | keyword() | map()) :: {integer(), integer()}
  def get_limit_bounds(options) do
    max_limit = options[:max_limit] || 100
    default_limit = options[:default_limit] || 10
    {max_limit, default_limit}
  end

  @doc """
  Extracts and validates the skip value from the given parameters.

  ## Parameters
  - `params`: A keyword list containing the `:skip` value.

  ## Examples
      iex> FatEcto.Pagination.Helper.get_skip_value(skip: 20)
      {20, []}
  """
  @spec get_skip_value(keyword()) :: {integer(), keyword()}
  def get_skip_value(params) do
    {skip, params} = Keyword.pop(params, :skip, @min_skip)
    skip = SharedHelper.parse_integer!(skip)
    skip = if skip > @default_skip, do: skip, else: @default_skip
    {skip, params}
  end

  @doc """
  Extracts and validates the limit value from the given parameters.

  ## Parameters
  - `params`: A keyword list containing the `:limit` value.
  - `options`: A keyword list or map containing `max_limit` and `default_limit`.

  ## Examples
      iex> FatEcto.Pagination.Helper.get_limit_value([limit: 15], max_limit: 50, default_limit: 10)
      {15, []}
  """
  @spec get_limit_value(keyword(), nil | keyword() | map()) :: {integer(), keyword()}
  def get_limit_value(params, options \\ []) do
    {max_limit, default_limit} = get_limit_bounds(options)
    {limit, params} = Keyword.pop(params, :limit, default_limit)
    limit = SharedHelper.parse_integer!(limit)

    if is_nil(limit) do
      {default_limit, params}
    else
      limit = if limit > @min_limit, do: limit, else: @min_limit
      limit = if limit > max_limit, do: max_limit, else: limit
      {limit, params}
    end
  end
end
