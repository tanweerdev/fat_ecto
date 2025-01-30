defmodule FatEcto.FatHelper do
  @moduledoc false
  alias Ecto.Query
  require Ecto.Query
  @min_limit 0
  @min_skip 0
  @default_skip 0

  @spec get_limit_bounds(nil | keyword() | map()) :: {any(), any()}
  def get_limit_bounds(options) do
    max_limit = options[:max_limit] || 100
    default_limit = options[:default_limit] || 10
    {max_limit, default_limit}
  end

  @spec get_module_options(keyword, any, keyword) :: keyword
  def get_module_options(options, module, defaults \\ []) do
    opt_app = options[:otp_app]
    fat_ecto_configs = (opt_app && Application.get_env(opt_app, :fat_ecto)) || []
    root_module_configs = fat_ecto_configs[module] || []
    configs = Keyword.merge(defaults, fat_ecto_configs)
    configs = Keyword.merge(configs, root_module_configs)
    Keyword.merge(configs, options)
  end

  @doc """
    Return skip value from given params.
     ### Parameters
        - `params`  - skip values.
    ### Examples
        iex>  FatEcto.FatHelper.get_skip_value( params["skip"])
  """
  @spec get_skip_value(keyword()) :: {any(), keyword()}
  def get_skip_value(params) do
    {skip, params} = Keyword.pop(params, :skip, @min_skip)
    skip = FatUtils.Integer.parse!(skip)
    skip = if skip > @default_skip, do: skip, else: @default_skip
    {skip, params}
  end

  @doc """
    Return limit from given params options.
     ### Parameters
        - `limit`  - Number of Records vlaue.
    ### Examples
        iex>  FatEcto.FatHelper.get_limit_value( params["limit"])
  """
  @spec get_limit_value(keyword(), nil | keyword() | map()) :: {any(), keyword()}
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
    Return true or false on basis of given value.
    ### Parameters
        - `value`  - Value of the field.
    ### Examples
          iex>  FatEcto.FatHelper.fat_ecto_reserve_field?(value)
  """
  @spec fat_ecto_reserve_field?(any()) :: boolean()
  def fat_ecto_reserve_field?(value) do
    cond do
      is_number(value) ->
        false

      is_binary(value) && String.starts_with?(value, "$") == true ->
        true

      true ->
        false
    end
  end

  @spec string_to_atom(any()) :: any()
  def string_to_atom(str) do
    String.to_atom(str)
  end

  @spec string_to_existing_atom(any()) :: any()
  def string_to_existing_atom(str) do
    String.to_existing_atom(str)
  end

  @spec model_related_owner(atom(), any()) :: %{
          owner: any(),
          owner_key: any(),
          related: any(),
          related_key: any()
        }
  def model_related_owner(model, relation_name) do
    case model.__schema__(:association, relation_name) do
      %Ecto.Association.Has{
        owner: owner,
        owner_key: owner_key,
        related: related,
        related_key: related_key
      } ->
        %{
          owner: owner,
          owner_key: owner_key,
          related: related,
          related_key: related_key
        }

      %Ecto.Association.BelongsTo{
        owner: owner,
        owner_key: owner_key,
        related: related,
        related_key: related_key
      } ->
        %{
          owner: owner,
          owner_key: owner_key,
          related: related,
          related_key: related_key
        }

      %Ecto.Association.ManyToMany{
        owner: owner,
        owner_key: owner_key,
        related: related
        # related_key: related_key
      } ->
        %{
          owner: owner,
          owner_key: owner_key,
          related: related,
          related_key: nil
        }

      %Ecto.Association.HasThrough{
        owner: owner,
        owner_key: owner_key
        # related: related
        # related_key: related_key
      } ->
        %{
          owner: owner,
          owner_key: owner_key,
          related: nil,
          related_key: nil
        }
    end
  end

  @spec dynamic_binding(map()) :: map()
  def dynamic_binding(map) when is_map(map), do: map(map, false)
  defp do_binding(_key, value, _nested) when not is_map(value), do: value
  defp do_binding("$" <> _key, value, nested), do: map(value, nested)
  defp do_binding(_key, value, nested), do: value |> map(true) |> put_binding(nested)
  defp map(map, nested), do: :maps.map(&do_binding(&1, &2, nested), map)
  defp put_binding(map, false), do: Map.put_new(map, "$binding", :first)
  defp put_binding(map, true), do: Map.put_new(map, "$binding", :last)

  @spec get_primary_keys(any()) :: any()
  def get_primary_keys(query) do
    %{source: {_table, model}} = query.from

    case model do
      nil ->
        nil

      _ ->
        model.__schema__(:primary_key)
    end
  end

  @spec dynamic_preloading(map()) :: any()
  def dynamic_preloading(map) when is_map(map), do: do_preloading(map)
  defp do_preloading(map), do: Enum.reduce(map, [], &do_preloading/2)

  defp do_preloading({key, %{"$include" => include}}, acc) when is_map(include),
    do: [{String.to_atom(key), do_preloading(include)} | acc]

  defp do_preloading({key, %{"$include" => include}}, acc) when is_bitstring(include),
    do: [{String.to_atom(key), String.to_atom(include)} | acc]

  defp do_preloading({key, %{"$include" => include}}, acc) when is_list(include),
    do: [{String.to_atom(key), Enum.map(include, &String.to_atom/1)} | acc]

  defp do_preloading({key, %{"$binding" => :last}}, acc), do: [String.to_atom(key) | acc]
  defp do_preloading({key, %{"$binding" => :first}}, acc), do: [String.to_atom(key) | acc]
  defp do_preloading({_key, _value}, acc), do: acc
  @spec remove_conflicting_order_by(any(), any()) :: any()
  def remove_conflicting_order_by(queryable, nil), do: queryable

  def remove_conflicting_order_by(queryable, _distinct) do
    case queryable do
      queryable when is_map(queryable) ->
        %{order_bys: order} = queryable

        if Enum.empty?(order) do
          queryable
        else
          Query.exclude(queryable, :order_by)
        end

      _ ->
        queryable
    end
  end
end
