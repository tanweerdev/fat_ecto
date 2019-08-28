defmodule FatEcto.FatQuery.FatDistinct do
  import Ecto.Query
  alias FatEcto.FatHelper
  alias FatEcto.FatHelper

  def build_distinct(queryable, nil, _options) do
    queryable
  end

  def build_distinct(queryable, field, options) when is_boolean(field) do
    FatHelper.params_valid(queryable, field, options[:otp_app])

    from(q in queryable,
      distinct: ^field
    )
  end

  def build_distinct(queryable, field, options) do
    FatHelper.params_valid(queryable, field, options[:otp_app])

    from(q in queryable,
      distinct: ^FatHelper.string_to_atom(field)
    )
  end
end
