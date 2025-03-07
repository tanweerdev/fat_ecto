defmodule FatEcto.FatHelper do
  @moduledoc """
  Provides utility functions for FatEcto, including handling pagination limits, skip values,
  dynamic binding, and preloading associations.
  """

  require Ecto.Query

  @min_limit 0
  @min_skip 0
  @default_skip 0

  @doc """
  Checks if a module implements the given behaviour by inspecting its `__info__/1` metadata.

  ## Parameters
  - `module`: The module to check.
  - `behaviour`: The behaviour to validate against.

  ## Examples
      iex> implements_behaviour?(MyApp.Repo, Ecto.Repo)
      true

      iex> implements_behaviour?(NotARepo, Ecto.Repo)
      false
  """
  @spec implements_behaviour?(module(), module()) :: boolean()
  def implements_behaviour?(module, behaviour) do
    is_atom(module) &&
      Code.ensure_compiled(module) &&
      function_exported?(module, :__info__, 1) &&
      :attributes
      |> module.__info__()
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(behaviour)
  end

  @doc """
  Returns the maximum and default limit values based on the provided options.

  ## Parameters
  - `options`: A keyword list or map containing `max_limit` and `default_limit`.

  ## Examples
      iex> FatEcto.FatHelper.get_limit_bounds(max_limit: 50, default_limit: 10)
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
      iex> FatEcto.FatHelper.get_skip_value(skip: 20)
      {20, []}
  """
  @spec get_skip_value(keyword()) :: {integer(), keyword()}
  def get_skip_value(params) do
    {skip, params} = Keyword.pop(params, :skip, @min_skip)
    skip = FatEcto.Utils.Integer.parse!(skip)
    skip = if skip > @default_skip, do: skip, else: @default_skip
    {skip, params}
  end

  @doc """
  Extracts and validates the limit value from the given parameters.

  ## Parameters
  - `params`: A keyword list containing the `:limit` value.
  - `options`: A keyword list or map containing `max_limit` and `default_limit`.

  ## Examples
      iex> FatEcto.FatHelper.get_limit_value([limit: 15], max_limit: 50, default_limit: 10)
      {15, []}
  """
  @spec get_limit_value(keyword(), nil | keyword() | map()) :: {integer(), keyword()}
  def get_limit_value(params, options \\ []) do
    {max_limit, default_limit} = get_limit_bounds(options)
    {limit, params} = Keyword.pop(params, :limit, default_limit)
    limit = FatEcto.Utils.Integer.parse!(limit)

    if is_nil(limit) do
      {default_limit, params}
    else
      limit = if limit > @min_limit, do: limit, else: @min_limit
      limit = if limit > max_limit, do: max_limit, else: limit
      {limit, params}
    end
  end

  @doc """
  Determines if a value is a reserved field in FatEcto.

  ## Parameters
  - `value`: The value to check.

  ## Examples
      iex> FatEcto.FatHelper.fat_ecto_reserve_field?("$INCLUDE")
      true
  """
  @spec fat_ecto_reserve_field?(any()) :: boolean()
  def fat_ecto_reserve_field?(value) do
    is_binary(value) && String.starts_with?(value, "$")
  end

  @doc """
  Converts a string to an atom.

  ## Parameters
  - `str`: The string to convert.

  ## Examples
      iex> FatEcto.FatHelper.string_to_atom("example")
      :example
  """
  @spec string_to_atom(String.t() | atom()) :: atom()
  def string_to_atom(already_atom) when is_atom(already_atom), do: already_atom
  def string_to_atom(str), do: String.to_atom(str)

  @doc """
  Converts a string to an existing atom.

  ## Parameters
  - `str`: The string to convert.

  ## Examples
      iex> FatEcto.FatHelper.string_to_existing_atom("example")
      :example
  """
  @spec string_to_existing_atom(String.t() | atom()) :: atom()
  def string_to_existing_atom(already_atom) when is_atom(already_atom), do: already_atom
  def string_to_existing_atom(str), do: String.to_existing_atom(str)

  @doc """
  Retrieves the primary keys for a given query.

  ## Parameters
  - `query`: The Ecto query.

  ## Examples
      iex> FatEcto.FatHelper.get_primary_keys(from(u in User))
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
end
