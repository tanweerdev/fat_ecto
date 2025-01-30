defmodule MyApp.RoomFilter do
  use FatEcto.FatQuery.Filterable,
    fields_allowed: %{},
    fields_not_allowed: %{
      "name" => "*",
      "phone" => "$ilike",
      "purpose" => "$in",
      "description" => "$equal"
    },
    ignoreable_fields_values: %{
      "name" => "%%",
      "phone" => "%%",
      "purpose" => [],
      "description" => nil
    }

  import Ecto.Query

  def not_allowed_fields_filter_fallback(query, "phone", "$ilike", compare_with) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^compare_with))
  end

  def not_allowed_fields_filter_fallback(query, "name", "$like", compare_with) do
    where(query, [r], like(fragment("(?)::TEXT", r.name), ^compare_with))
  end

  def not_allowed_fields_filter_fallback(query, "description", "$equal", compare_with) do
    where(query, [r], r.description == ^compare_with)
  end

  def not_allowed_fields_filter_fallback(query, "purpose", "$in", compare_with) do
    where(query, [r], r.purpose in ^compare_with)
  end

  def not_allowed_fields_filter_fallback(query, _, _, _) do
    query
  end
end
