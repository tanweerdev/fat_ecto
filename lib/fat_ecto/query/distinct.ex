defmodule FatEcto.FatQuery.FatDistinct do
  import Ecto.Query
  alias FatEcto.FatHelper
  alias FatEcto.FatHelper

  def build_distinct(queryable, nil, _options) do
    queryable
  end

  def build_distinct(queryable, field, options) when is_boolean(field) do
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
  end

  def build_distinct(queryable, field, options) do
    FatHelper.params_valid(queryable, field, options)

    from(q in queryable,
      distinct: ^FatHelper.string_to_atom(field)
    )
  end
end
