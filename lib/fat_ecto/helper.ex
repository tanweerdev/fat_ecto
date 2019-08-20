defmodule FatEcto.FatHelper do
  @moduledoc false
  # alias FatEcto.FatHelper

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

  # TODO: Add docs and examples for ex_doc
  @spec get_skip_value(keyword()) :: {any(), keyword()}
  def get_skip_value(params) do
    {skip, params} = Keyword.pop(params, :skip, @min_skip)
    skip = FatUtils.Integer.parse!(skip)
    skip = if skip > @default_skip, do: skip, else: @default_skip
    {skip, params}
  end

  # TODO: Add docs and examples for ex_doc
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

  # TODO: Add docs and examples for ex_doc
  @spec is_fat_ecto_field?(any()) :: boolean()
  def is_fat_ecto_field?(value) do
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
    end
  end

  def restrict_params(select_params, app) do
    blacklist_params_list = Application.get_env(app, :fat_ecto)[:blacklist_params]

    case blacklist_params_list do
      nil ->
        select_params

      _ ->
        select_params -- blacklist_params_list
    end
  end
end
