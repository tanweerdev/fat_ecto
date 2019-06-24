defmodule FatEcto.FatQuery.FatDistinct do
  import Ecto.Query
  alias FatEcto.FatHelper

  def build_distinct(queryable, nil) do
    queryable
  end

  def build_distinct(queryable, field) when is_boolean(field) do
    from(q in queryable,
      distinct: ^field
    )
  end

  def build_distinct(queryable, field) do
    from(q in queryable,
      distinct: ^FatHelper.string_to_atom(field)
    )
  end
end
