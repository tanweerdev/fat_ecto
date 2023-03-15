defmodule MyApp.PatientFilter do
  use FatEcto.FatQuery.Filterable,
    fields_allowed: %{},
    fields_not_allowed: %{}
end
