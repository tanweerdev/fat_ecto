defmodule MyApp.RoomFilter do
  import Ecto.Query

  use FatEcto.FatQuery.Filterable,
    fields_allowed: %{},
    fields_not_allowed: %{
      "name" => "*",
      "phone" => "$ilike"
    }

  def not_allowed_fields_filter_fallback(query, "phone", "$ilike", compare_with) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^compare_with))
  end

  def not_allowed_fields_filter_fallback(query, "name", "$like", compare_with) do
    where(query, [r], like(fragment("(?)::TEXT", r.name), ^compare_with))
  end

  def not_allowed_fields_filter_fallback(query, _, _, _) do
    query
  end
end
