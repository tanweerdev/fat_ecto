# defmodule MyApp.DoctorOrderby do
#   use FatEcto.FatQuery.Sortable,
#     allowed_fields: %{
#       "email" => "$desc",
#       "phone" => "$asc"
#     },
#     customizable_fields: %{
#       "phone" => "$desc"
#     }
# end
