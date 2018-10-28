defmodule FatEcto.FatHelper do
  @moduledoc false

  require Ecto.Query
  @min_limit 0
  @max_limit Application.get_env(:fat_ecto, :repo)[:max_limit] || 100
  @default_limit Application.get_env(:fat_ecto, :repo)[:default_limit] || 10

  @min_skip 0
  @default_skip 0

  # TODO: Add docs and examples for ex_doc
  def get_skip_value(params) do
    {skip, params} = Keyword.pop(params, :skip, @min_skip)
    skip = Ex.IntegerUtils.parse!(skip)
    skip = if skip > @default_skip, do: skip, else: @default_skip
    {skip, params}
  end

  # TODO: Add docs and examples for ex_doc
  def get_limit_value(params) do
    {limit, params} = Keyword.pop(params, :limit, @default_limit)
    limit = Ex.IntegerUtils.parse!(limit)
    limit = if limit > @min_limit, do: limit, else: @min_limit
    limit = if limit > @max_limit, do: @max_limit, else: limit
    {limit, params}
  end

  # TODO: Add docs and examples for ex_doc
  def to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end

  defp schema_fields(%{from: {_source, schema}}) when schema != nil,
    do: schema.__schema__(:fields)

  defp schema_fields(_query), do: nil

  # TODO: Add docs and examples for ex_doc
  def field_exists?(queryable, column) do
    query = Ecto.Queryable.to_query(queryable)
    fields = schema_fields(query)

    if fields == nil do
      true
    else
      Enum.member?(fields, column)
    end
  end

  # TODO: Add docs and examples for ex_doc
  def get_limit(limit_param) do
    limit = Ex.IntegerUtils.parse!(limit_param || @default_limit)
    limit = if limit > @min_limit, do: limit, else: @min_limit
    if limit > @max_limit, do: @max_limit, else: limit
  end

  # TODO: Add docs and examples for ex_doc
  def fields(select) do
    map = select
    fields = map["$fields"]
    Enum.map(fields, &string_to_existing_atom/1)
  end

  # TODO: Add docs and examples for ex_doc
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

  # TODO: Add docs and examples for ex_doc
  def associations(model, relation_name, fields, assoc_fields) do
    case model.__schema__(:association, relation_name) do
      %Ecto.Association.Has{
        owner: _owner,
        owner_key: owner_key,
        related: _related,
        related_key: _related_key
      } ->
        fields ++
          [owner_key] ++ [{relation_name, Enum.map(assoc_fields, &string_to_existing_atom/1)}]

      %Ecto.Association.BelongsTo{
        owner: _owner,
        owner_key: owner_key,
        related: _related,
        related_key: _related_key
      } ->
        fields ++
          [owner_key] ++ [{relation_name, Enum.map(assoc_fields, &string_to_existing_atom/1)}]

      nil ->
        fields
    end
  end

  defp replacement_for(key, tuple) do
    map = Enum.into(tuple, %{})

    if Map.has_key?(map, to_string(key)) do
      tuple
      |> Enum.find(fn {x, _} -> x == to_string(key) end)
      |> elem(1)
    else
      key
    end
  end

  # TODO: Add docs and examples for ex_doc
  def replace_keys(map, tuple) do
    for {k, v} <- map, into: %{}, do: {replacement_for(k, tuple), v}
  end

  # TODO: Add docs and examples for ex_doc
  def field_exists(queryable, opts_select, model) do
    queryable_schema_fields = queryable.__schema__(:fields)
    model_schema_fields = model.__schema__(:fields)
    values = Map.values(opts_select)
    map_keys = Enum.map(values, &Map.keys/1)
    single_list = Enum.at(map_keys, 0)
    asso_model = single_list -- ["$fields"]
    asso_model_name = Enum.at(asso_model, 0)
    queryable_fields = opts_select["$select"]["$fields"]
    model_fields = opts_select["$select"][asso_model_name]

    queryable_f_exists = Enum.map(queryable_fields, &string_to_atom/1) -- queryable_schema_fields

    model_f_exists = Enum.map(model_fields, &string_to_atom/1) -- model_schema_fields
    queryable_f_exists ++ model_f_exists
  end

  def string_to_atom(str) do
    String.to_atom(str)
  end

  def string_to_existing_atom(str) do
    String.to_existing_atom(str)
  end

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
end
