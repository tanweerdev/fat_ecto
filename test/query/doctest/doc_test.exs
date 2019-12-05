defmodule DocTest do
  use ExUnit.Case, async: true
  doctest FatEcto.FatQuery.FatWhere
  doctest MyApp.Query, import: true, except: [fetch: 2, paginate: 2]
  doctest FatEcto.FatQuery.FatOrderBy
end
