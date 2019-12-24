defmodule FatEcto.FatQuery.FatDistinct do
  import Ecto.Query
  alias FatEcto.FatHelper
  alias FatEcto.FatHelper

  def build_distinct(queryable, nil, _order_by,  _options) do
    queryable
  end

  def build_distinct(queryable, field, order_by, options) when is_boolean(field) do
    if order_by == nil do
    FatHelper.params_valid(queryable, field, options)

    schema =
      case queryable do
        queryable when is_map(queryable) ->
          %Ecto.Query.FromExpr{
            source: {_table, schema}
          } = queryable.from

          schema

        _ ->
          queryable
      end

    from(q in queryable,
      distinct: ^schema.__schema__(:primary_key)
    )
  else
    Enum.reduce(order_by, queryable, fn {k, v}, queryable ->
      if v == "$asc" do
        from(q in queryable,
          distinct: [asc: field(q, ^FatHelper.string_to_existing_atom(k))]
        )
      else
        from(q in queryable,
          distinct: [desc: field(q, ^FatHelper.string_to_existing_atom(k))]
        )
      end
    end)
  end
  end

  def build_distinct(queryable, field, _order_by, options) do
    FatHelper.params_valid(queryable, field, options)

    from(q in queryable,
      distinct: ^FatHelper.string_to_atom(field)
    )
  end
end
