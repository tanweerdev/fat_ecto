defmodule FatEcto.MacrosHelper do
  def get_record(id, repo, schema) do
    case repo.get(schema, id) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
