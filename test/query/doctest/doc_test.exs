defmodule DocTest do
  use ExUnit.Case, async: true
  doctest MyApp.Query, import: true, except: [fetch: 2, paginate: 2]

  doctest FatEcto.FatPaginator

  doctest FatEcto.FatQuery.FatWhere
  doctest FatEcto.FatQuery.FatOrderBy
  doctest FatEcto.FatQuery.FatDynamics
  doctest FatEcto.FatQuery.FatNotDynamics
  doctest FatEcto.FatQuery.FatGroupBy
  doctest FatEcto.FatQuery.FatInclude
  doctest FatEcto.FatQuery.FatAggregate
  doctest FatEcto.FatQuery.FatDistinct
  doctest FatEcto.FatQuery.FatJoin
end
