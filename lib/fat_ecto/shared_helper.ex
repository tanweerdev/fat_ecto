defmodule FatEcto.SharedHelper do
  @moduledoc """
  Provides utility functions for FatEcto, including handling pagination limits, skip values,
  dynamic binding, and preloading associations.
  """

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
  Converts a string to an atom.

  ## Parameters
  - `str`: The string to convert.

  ## Examples
      iex> FatEcto.SharedHelper.string_to_atom("example")
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
      iex> FatEcto.SharedHelper.string_to_existing_atom("example")
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

  @spec filterable_opt_to_map(maybe_improper_list() | any()) :: maybe_improper_list() | map()
  def filterable_opt_to_map(list) when is_list(list) do
    if Keyword.keyword?(list) do
      keyword_list_to_map(list)
    else
      list
      |> Enum.map(fn k -> {Atom.to_string(k), "*"} end)
      |> Map.new()
    end
  end

  def filterable_opt_to_map(input), do: input

  # Converts a keyword list to a map with string keys
  @spec keyword_list_to_map(keyword() | map()) :: map()
  def keyword_list_to_map(list) when is_list(list) do
    if Keyword.keyword?(list) do
      list
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
      |> Map.new()
    else
      list
    end
  end

  def keyword_list_to_map(input), do: input
end
