defmodule FatEcto.Pagination.Helper do
  @moduledoc """
  Provides utility functions for FatEcto, including handling pagination limits, skip values,
  dynamic binding, and preloading associations.
  """

  require Ecto.Query

  @min_limit 0
  @min_skip 0
  @default_skip 0

  @doc """
  Returns the maximum and default limit values based on the provided options.

  ## Parameters
  - `options`: A keyword list or map containing `max_limit` and `default_limit`.

  ## Examples
      iex> FatEcto.SharedHelper.get_limit_bounds(max_limit: 50, default_limit: 10)
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
    skip = parse_integer!(skip)
    skip = if skip > @default_skip, do: skip, else: @default_skip
    {skip, params}
  end

  @doc """
  Extracts and validates the limit value from the given parameters.

  ## Parameters
  - `params`: A keyword list containing the `:limit` value.
  - `options`: A keyword list or map containing `max_limit` and `default_limit`.

  ## Examples
      iex> FatEcto.SharedHelper.get_limit_value([limit: 15], max_limit: 50, default_limit: 10)
      {15, []}
  """
  @spec get_limit_value(keyword(), nil | keyword() | map()) :: {integer(), keyword()}
  def get_limit_value(params, options \\ []) do
    {max_limit, default_limit} = get_limit_bounds(options)
    {limit, params} = Keyword.pop(params, :limit, default_limit)
    limit = parse_integer!(limit)

    if is_nil(limit) do
      {default_limit, params}
    else
      limit = if limit > @min_limit, do: limit, else: @min_limit
      limit = if limit > max_limit, do: max_limit, else: limit
      {limit, params}
    end
  end

  @doc """
  Retrieves the primary keys for a given query.

  ## Parameters
  - `query`: The Ecto query.

  ## Examples
      iex> FatEcto.SharedHelper.get_primary_keys(from(u in User))
      [:id]
  """
  @spec get_primary_keys(Ecto.Query.t()) :: list(atom()) | nil
  def get_primary_keys(query) do
    %{source: {_table, model}} = query.from

    if model do
      model.__schema__(:primary_key)
    else
      nil
    end
  end

  defp parse_integer!(int_str) do
    cond do
      is_integer(int_str) -> int_str
      is_binary(int_str) -> do_parse_integer(int_str)
      true -> nil
    end
  end

  # Helper function to parse an integer from a string
  defp do_parse_integer(int_str) do
    case Integer.parse(int_str) do
      {integer, _} -> integer
      :error -> nil
    end
  end
end
