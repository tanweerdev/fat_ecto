defmodule MyApp.DoctorFilter do
  use FatEcto.FatQuery.Whereable,
    filterable_fields: %{
      "email" => [
        "$equal",
        "$like",
        "$not_equal",
        "$not_like",
        "$ilike",
        "$in",
        "$not_ilike",
        "$not_in",
        "$not_null",
        "$null"
      ],
      "name" => "*",
      "rating" => "*",
      "start_date" => "*",
      "location" => "*"
    },
    overrideable_fields: ["phone"],
    ignoreable_fields_values: %{
      "email" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }

  import Ecto.Query
  @impl FatEcto.FatQuery.Whereable

  def override_whereable(query, "phone", "$ilike", value) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^value))
  end

  def override_whereable(query, "phone", "$like", value) do
    where(query, [r], like(fragment("(?)::TEXT", r.phone), ^value))
  end

  def override_whereable(query, _, _, _) do
    query
  end
end
