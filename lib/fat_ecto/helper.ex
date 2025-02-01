defmodule FatEcto.FatHelper do
  @moduledoc """
  Provides utility functions for FatEcto, including handling pagination limits, skip values,
  dynamic binding, and preloading associations.
  """

  alias Ecto.Query
  require Ecto.Query

  @min_limit 0
  @min_skip 0
  @default_skip 0

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
  Merges module-specific options with global and root-level configurations.

  ## Parameters
  - `options`: A keyword list of options.
  - `module`: The module for which options are being configured.
  - `defaults`: Default options to merge.

  ## Examples
      iex> FatEcto.FatHelper.get_module_options([max_limit: 50], MyApp.MyContext)
      [max_limit: 50, default_limit: 10]
  """
  @spec get_module_options(keyword(), module(), keyword()) :: keyword()
  def get_module_options(options, module, defaults \\ []) do
    opt_app = options[:otp_app]
    fat_ecto_configs = (opt_app && Application.get_env(opt_app, :fat_ecto)) || []
    root_module_configs = fat_ecto_configs[module] || []
    configs = Keyword.merge(defaults, fat_ecto_configs)
    configs = Keyword.merge(configs, root_module_configs)
    Keyword.merge(configs, options)
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
    skip = FatUtils.Integer.parse!(skip)
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
    limit = FatUtils.Integer.parse!(limit)

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
      iex> FatEcto.FatHelper.fat_ecto_reserve_field?("$include")
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
  @spec string_to_atom(String.t()) :: atom()
  def string_to_atom(str), do: String.to_atom(str)

  @doc """
  Converts a string to an existing atom.

  ## Parameters
  - `str`: The string to convert.

  ## Examples
      iex> FatEcto.FatHelper.string_to_existing_atom("example")
      :example
  """
  @spec string_to_existing_atom(String.t()) :: atom()
  def string_to_existing_atom(str), do: String.to_existing_atom(str)

  @doc """
  Retrieves the owner and related association details for a given model and relation.

  ## Parameters
  - `model`: The Ecto model.
  - `relation_name`: The name of the association.

  ## Examples
      iex> FatEcto.FatHelper.model_related_owner(MyApp.User, :posts)
      %{owner: MyApp.User, owner_key: :user_id, related: MyApp.Post, related_key: :id}
  """
  @spec model_related_owner(module(), atom()) :: %{
          owner: module(),
          owner_key: atom(),
          related: module(),
          related_key: atom() | nil
        }
  def model_related_owner(model, relation_name) do
    case model.__schema__(:association, relation_name) do
      %Ecto.Association.Has{
        owner: owner,
        owner_key: owner_key,
        related: related,
        related_key: related_key
      } ->
        %{owner: owner, owner_key: owner_key, related: related, related_key: related_key}

      %Ecto.Association.BelongsTo{
        owner: owner,
        owner_key: owner_key,
        related: related,
        related_key: related_key
      } ->
        %{owner: owner, owner_key: owner_key, related: related, related_key: related_key}

      %Ecto.Association.ManyToMany{
        owner: owner,
        owner_key: owner_key,
        related: related
      } ->
        %{owner: owner, owner_key: owner_key, related: related, related_key: nil}

      %Ecto.Association.HasThrough{
        owner: owner,
        owner_key: owner_key
      } ->
        %{owner: owner, owner_key: owner_key, related: nil, related_key: nil}
    end
  end

  @doc """
  Adds dynamic binding information to a map.

  ## Parameters
  - `map`: The map to process.

  ## Examples
      iex> FatEcto.FatHelper.dynamic_binding(%{"$include" => %{"key" => "value"}})
      %{"$include" => %{"key" => "value", "$binding" => :first}}
  """
  @spec dynamic_binding(map()) :: map()
  def dynamic_binding(map) when is_map(map), do: map(map, false)

  defp do_binding(_key, value, _nested) when not is_map(value), do: value
  defp do_binding("$" <> _key, value, nested), do: map(value, nested)
  defp do_binding(_key, value, nested), do: value |> map(true) |> put_binding(nested)
  defp map(map, nested), do: :maps.map(&do_binding(&1, &2, nested), map)
  defp put_binding(map, false), do: Map.put_new(map, "$binding", :first)
  defp put_binding(map, true), do: Map.put_new(map, "$binding", :last)

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

  @doc """
  Dynamically preloads associations based on a map.

  ## Parameters
  - `map`: The map containing preloading instructions.

  ## Examples
      iex> FatEcto.FatHelper.dynamic_preloading(%{"posts" => %{"$include" => "comments"}})
      [posts: :comments]
  """
  @spec dynamic_preloading(map()) :: list({atom(), atom() | list(atom())})
  def dynamic_preloading(map) when is_map(map), do: do_preloading(map)

  defp do_preloading(map), do: Enum.reduce(map, [], &do_preloading/2)

  defp do_preloading({key, %{"$include" => include}}, acc) when is_map(include),
    do: [{String.to_atom(key), do_preloading(include)} | acc]

  defp do_preloading({key, %{"$include" => include}}, acc) when is_bitstring(include),
    do: [{String.to_atom(key), String.to_atom(include)} | acc]

  defp do_preloading({key, %{"$include" => include}}, acc) when is_list(include),
    do: [{String.to_atom(key), Enum.map(include, &String.to_atom/1)} | acc]

  defp do_preloading({key, %{"$binding" => binding}}, acc) when binding in [:first, :last],
    do: [String.to_atom(key) | acc]

  defp do_preloading({_key, _value}, acc), do: acc

  @doc """
  Removes conflicting `order_by` clauses from a query.

  ## Parameters
  - `queryable`: The Ecto query.
  - `distinct`: The distinct clause.

  ## Examples
      iex> FatEcto.FatHelper.remove_conflicting_order_by(from(u in User), nil)
      #Ecto.Query<from u in User>
  """
  @spec remove_conflicting_order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def remove_conflicting_order_by(queryable, nil), do: queryable

  def remove_conflicting_order_by(queryable, _distinct) do
    case queryable do
      %{order_bys: order_bys} when order_bys != [] ->
        Query.exclude(queryable, :order_by)

      _ ->
        queryable
    end
  end
end
