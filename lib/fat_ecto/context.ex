defmodule FatEcto.Context do
  import Ecto.Query, warn: false
  @repo Application.get_env(:fat_ecto, :repo)[:query_repo]
  # alias MyApp.{Repo}

  # get first record
  # user = FatEcto.Context.first(MyApp.User)
  # TODO: add order_by support dynamicall and let user define default order_by in config
  def first(schema, preloads \\ []) do
    query =
      cond do
        # Enum.member?(schema.__schema__(:fields), :id) &&
        #     schema.__schema__(:field_source, :id) == :id ->
        #   from(q in schema, order_by: q.id, limit: 1)

        # Enum.member?(schema.__schema__(:fields), :inserted_at) &&
        #     schema.__schema__(:field_source, :inserted_at) == :naive_datetime ->
        #   from(q in schema, order_by: q.inserted_at, limit: 1)

        true ->
          from(q in schema, limit: 1)
      end

    @repo.one(from(q in query, preload: ^preloads))
  end

  # get last record
  def last(schema, preloads \\ []) do
    query =
      cond do
        # Enum.member?(schema.__schema__(:fields), :id) &&
        #     schema.__schema__(:field_source, :id) == :id ->
        #   from(q in schema, order_by: [desc: q.id], limit: 1)

        # Enum.member?(schema.__schema__(:fields), :inserted_at) &&
        #     schema.__schema__(:field_source, :inserted_at) == :naive_datetime ->
        #   from(q in schema, order_by: [desc: q.inserted_at], limit: 1)

        true ->
          from(q in schema, limit: 1)
      end

    @repo.one(from(q in query, preload: ^preloads))
  end

  # Context.count(User)
  def count(schema) do
    query = from(q in schema, select: fragment("count(*)"))
    @repo.one(query)
  end

  # Context.count(User, username: "name")
  def count(schema, keyword_cond) do
    query = Ecto.Query.where(schema, ^keyword_cond)
    query = from(q in query, select: fragment("count(*)"))
    @repo.one(query)
  end

  # Context.list(User, [:actions]) or Context.list(User)
  def list(schema, preloads \\ []) do
    # query =
    #   if Enum.member?(schema.__schema__(:fields), :name) do
    #     from(q in schema, order_by: q.name)
    #   else
    #     schema
    #   end

    @repo.all(schema) |> @repo.preload(preloads)
  end

  # Context.get!(User, 2)
  def get!(schema, id), do: @repo.get!(schema, id)

  # Context.get(User, 2, assoc)
  def get(schema, id, preloads \\ []) do
    schema
    |> @repo.get(id)
    |> @repo.preload(preloads)
  end

  def get_catch(schema, id, preloads \\ []) do
    try do
      schema
      |> @repo.get(id)
      |> @repo.preload(preloads)
    rescue
      _ in _ -> {:error, :invalid_id}
    end
  end

  # Context.get_by(User, name: name) OR
  # Context.get_by(User, [name: name], [:actions])
  def get_by(schema, clauses, preloads \\ []) do
    schema
    |> @repo.get_by(clauses)
    |> @repo.preload(preloads)
  end

  # Context.create(User, %{name: "John Doe"})
  def create(schema, attrs) do
    schema.__struct__
    |> schema.changeset(attrs)
    |> @repo.insert()
  end

  # Context.update(User, %User{name: "old name", id: ...}, %{name: "new name"})
  def update(schema, item, attrs) do
    item
    |> schema.changeset(attrs)
    |> @repo.update()
  end

  # Context.delete(%User{name: "name", id: 1})
  def delete(item) do
    @repo.delete(item)
  end

  # Context.delete_all(User)
  # Context.delete_all(from a in User, where: a.id in [1, 2])
  def delete_all(schema) do
    @repo.delete_all(schema)
  end

  # Context.changeset(User, %{id: 1, name: "somename"})
  def changeset(schema, item, params \\ %{}) do
    schema.changeset(item, params)
  end

  # Context.get_all_by(User, name: "somename", [:actions])
  def get_all_by(schema, keyword_cond, preloads \\ []) do
    # query =
    #   if Enum.member?(schema.__schema__(:fields), :name) do
    #     from(q in schema, order_by: q.name)
    #   else
    #     schema
    #   end

    schema
    |> @repo.get_all_by(keyword_cond)
    |> @repo.preload(preloads)
  end
end
