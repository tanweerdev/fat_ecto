defmodule FatEcto.MacrosHelper do
  import Ecto.Query

  def get_record(id, repo, schema) do
    case repo.get(schema, id) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  def get_record_by_query(field, value, repo, query) do
    query = from(q in query, where: field(q, ^field) == ^value, limit: 1)

    case repo.one(query) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  def preload_record(record, repo, preloads) do
    case record do
      nil ->
        nil

      record ->
        if preloads do
          repo.preload(record, preloads)
        else
          record
        end
    end
  end
end
