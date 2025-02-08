defmodule FatEcto.FatContext do
  @moduledoc """
  Provides a set of utility functions to simplify common Ecto operations such as querying, creating, updating, and deleting records.

  This module is designed to be used within a context module to provide a consistent and easy-to-use API for interacting with your database.

  ## Usage

      defmodule FatEcto.FatUserContext do
        use FatEcto.FatContext, repo: Fat.Repo

        # Custom functions can be added here
      end

  Now you can use the functions provided by `FatEcto.FatContext` within `FatEcto.FatUserContext`.
  """

  defmacro __using__(options \\ []) do
    quote location: :keep do
      @options unquote(options)
      @repo @options[:repo] || raise("Please define :repo when using FatEcto.FatContext")

      import Ecto.Query, warn: false

      @doc """
      Retrieves the first record from the given schema.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `preloads`: A list of associations to preload (default: []).

      ## Examples
          iex> first(FatEcto.FatUser)
          %FatEcto.FatUser{}

          iex> first(FatEcto.FatUser, [:posts])
          %FatEcto.FatUser{posts: [%Fat.Post{}]}
      """
      def first(schema, preloads \\ []) do
        query =
          cond do
            has_field?(schema, :id) -> from(q in schema, order_by: q.id, limit: 1)
            has_field?(schema, :inserted_at) -> from(q in schema, order_by: q.inserted_at, limit: 1)
            true -> from(q in schema, limit: 1)
          end

        @repo.one(from(q in query, preload: ^preloads))
      end

      @doc """
      Retrieves the last record from the given schema.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `preloads`: A list of associations to preload (default: []).

      ## Examples
          iex> last(FatEcto.FatUser)
          %FatEcto.FatUser{}

          iex> last(FatEcto.FatUser, [:posts])
          %FatEcto.FatUser{posts: [%Fat.Post{}]}
      """
      def last(schema, preloads \\ []) do
        query =
          cond do
            has_field?(schema, :id) -> from(q in schema, order_by: [desc: q.id], limit: 1)
            has_field?(schema, :inserted_at) -> from(q in schema, order_by: [desc: q.inserted_at], limit: 1)
            true -> from(q in schema, limit: 1)
          end

        @repo.one(from(q in query, preload: ^preloads))
      end

      @doc """
      Counts the total number of records in the given schema.

      ## Parameters
      - `schema`: The Ecto schema module.

      ## Examples
          iex> count(FatEcto.FatUser)
          42
      """
      def count(schema) do
        query = from(q in schema, select: fragment("COUNT(*)"))
        @repo.one(query)
      end

      @doc """
      Counts the number of records that match the given conditions.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `conditions`: A keyword list of conditions.

      ## Examples
          iex> count(FatEcto.FatUser, name: "John Doe")
          1
      """
      def count(schema, conditions) do
        schema
        |> where(^conditions)
        |> select([q], fragment("COUNT(*)"))
        |> @repo.one()
      end

      @doc """
      Retrieves all records from the given schema and preloads the specified associations.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `preloads`: A list of associations to preload (default: []).

      ## Examples
          iex> list(FatEcto.FatUser)
          [%FatEcto.FatUser{}, %FatEcto.FatUser{}]

          iex> list(FatEcto.FatUser, [:posts])
          [%FatEcto.FatUser{posts: [%Fat.Post{}]}, %FatEcto.FatUser{posts: []}]
      """
      def list(schema, preloads \\ []) do
        schema |> @repo.all() |> @repo.preload(preloads)
      end

      @doc """
      Retrieves all records from the given schema that match the specified conditions and preloads the specified associations.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `conditions`: A keyword list of conditions.
      - `preloads`: A list of associations to preload (default: []).

      ## Examples
          iex> list_by(FatEcto.FatUser, name: "John Doe")
          [%FatEcto.FatUser{name: "John Doe"}]

          iex> list_by(FatEcto.FatUser, name: "John Doe", [:posts])
          [%FatEcto.FatUser{name: "John Doe", posts: [%Fat.Post{}]}]
      """
      def list_by(schema, conditions, preloads \\ []) do
        schema
        |> where(^conditions)
        |> @repo.all()
        |> @repo.preload(preloads)
      end

      @doc """
      Retrieves a record by its ID and raises if not found.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `id`: The ID of the record.

      ## Examples
          iex> get!(FatEcto.FatUser, 1)
          %FatEcto.FatUser{id: 1}

          iex> get!(FatEcto.FatUser, 999)
          ** (Ecto.NoResultsError)
      """
      def get!(schema, id), do: @repo.get!(schema, id)

      @doc """
      Retrieves a record by its ID and preloads the specified associations. Returns an error tuple if the record is not found.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `id`: The ID of the record.
      - `preloads`: A list of associations to preload (default: []).

      ## Examples
          iex> get(FatEcto.FatUser, 1)
          {:ok, %FatEcto.FatUser{id: 1}}

          iex> get(FatEcto.FatUser, 999)
          {:error, :not_found}

          iex> get(FatEcto.FatUser, 1, [:posts])
          {:ok, %FatEcto.FatUser{id: 1, posts: [%Fat.Post{}]}}
      """
      def get(schema, id, preloads \\ []) do
        case @repo.get(schema, id) do
          nil -> {:error, :not_found}
          record -> {:ok, @repo.preload(record, preloads)}
        end
      end

      @doc """
      Retrieves a record by the given conditions and preloads the specified associations. Returns an error tuple if the record is not found.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `conditions`: A keyword list of conditions.
      - `preloads`: A list of associations to preload (default: []).

      ## Examples
          iex> get_by(FatEcto.FatUser, name: "John Doe")
          {:ok, %FatEcto.FatUser{name: "John Doe"}}

          iex> get_by(FatEcto.FatUser, name: "Non-existent")
          {:error, :not_found}

          iex> get_by(FatEcto.FatUser, name: "John Doe", [:posts])
          {:ok, %FatEcto.FatUser{name: "John Doe", posts: [%Fat.Post{}]}}
      """
      def get_by(schema, conditions, preloads \\ []) do
        case @repo.get_by(schema, conditions) do
          nil -> {:error, :not_found}
          record -> {:ok, @repo.preload(record, preloads)}
        end
      end

      @doc """
      Creates a new record with the given attributes.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `attrs`: A map of attributes.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> create(FatEcto.FatUser, %{name: "John Doe"})
          {:ok, %FatEcto.FatUser{name: "John Doe"}}

          iex> create(FatEcto.FatUser, %{name: "John Doe"}, [returning: true])
          {:ok, %FatEcto.FatUser{name: "John Doe"}}
      """
      def create(schema, attrs, opts \\ []) do
        schema.__struct__()
        |> schema.changeset(attrs)
        |> @repo.insert(opts)
      end

      @doc """
      Creates a new record using a custom changeset function.

      ## Parameters
      - `struct`: The Ecto struct.
      - `changeset_fn`: A function that takes a struct and attributes and returns a changeset.
      - `attrs`: A map of attributes.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> create_by(%FatEcto.FatUser{}, &FatEcto.FatUser.changeset/2, %{name: "John Doe"})
          {:ok, %FatEcto.FatUser{name: "John Doe"}}
      """
      def create_by(struct, changeset_fn, attrs, opts \\ []) when is_function(changeset_fn, 2) do
        struct
        |> changeset_fn.(attrs)
        |> @repo.insert(opts)
      end

      @doc """
      Creates a new record with the given attributes and raises on failure.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `attrs`: A map of attributes.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> create!(FatEcto.FatUser, %{name: "John Doe"})
          %FatEcto.FatUser{name: "John Doe"}

          iex> create!(FatEcto.FatUser, %{name: nil})
          ** (Ecto.InvalidChangesetError)
      """
      def create!(schema, attrs, opts \\ []) do
        schema.__struct__()
        |> schema.changeset(attrs)
        |> @repo.insert!(opts)
      end

      @doc """
      Creates a new record using a custom changeset function and raises on failure.

      ## Parameters
      - `struct`: The Ecto struct.
      - `changeset_fn`: A function that takes a struct and attributes and returns a changeset.
      - `attrs`: A map of attributes.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> create_by!(%FatEcto.FatUser{}, &FatEcto.FatUser.changeset/2, %{name: "John Doe"})
          %FatEcto.FatUser{name: "John Doe"}
      """
      def create_by!(struct, changeset_fn, attrs, opts \\ []) when is_function(changeset_fn, 2) do
        struct
        |> changeset_fn.(attrs)
        |> @repo.insert!(opts)
      end

      @doc """
      Updates a record using a custom changeset function.

      ## Parameters
      - `record`: The record to update.
      - `changeset_fn`: A function that takes a record and attributes and returns a changeset.
      - `attrs`: A map of attributes.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> update_by(%FatEcto.FatUser{name: "Old Name"}, &FatEcto.FatUser.changeset/2, %{name: "New Name"})
          {:ok, %FatEcto.FatUser{name: "New Name"}}
      """
      def update_by(record, changeset_fn, attrs, opts \\ []) when is_function(changeset_fn, 2) do
        record
        |> changeset_fn.(attrs)
        |> @repo.update(opts)
      end

      @doc """
      Updates a record using the schema's changeset function.

      ## Parameters
      - `record`: The record to update.
      - `schema`: The Ecto schema module.
      - `attrs`: A map of attributes.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> update(%FatEcto.FatUser{name: "Old Name"}, FatEcto.FatUser, %{name: "New Name"})
          {:ok, %FatEcto.FatUser{name: "New Name"}}
      """
      def update(record, schema, attrs, opts \\ []) do
        record
        |> schema.changeset(attrs)
        |> @repo.update(opts)
      end

      @doc """
      Updates a record using a custom changeset function and raises on failure.

      ## Parameters
      - `record`: The record to update.
      - `changeset_fn`: A function that takes a record and attributes and returns a changeset.
      - `attrs`: A map of attributes.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> update_by!(%FatEcto.FatUser{name: "Old Name"}, &FatEcto.FatUser.changeset/2, %{name: "New Name"})
          %FatEcto.FatUser{name: "New Name"}
      """
      def update_by!(record, changeset_fn, attrs, opts \\ []) when is_function(changeset_fn, 2) do
        record
        |> changeset_fn.(attrs)
        |> @repo.update!(opts)
      end

      @doc """
      Updates a record using the schema's changeset function and raises on failure.

      ## Parameters
      - `record`: The record to update.
      - `schema`: The Ecto schema module.
      - `attrs`: A map of attributes.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> update!(%FatEcto.FatUser{name: "Old Name"}, FatEcto.FatUser, %{name: "New Name"})
          %FatEcto.FatUser{name: "New Name"}
      """
      def update!(record, schema, attrs, opts \\ []) do
        record
        |> schema.changeset(attrs)
        |> @repo.update!(opts)
      end

      @doc """
      Upserts a record based on the given conditions. If the record exists, it updates it; otherwise, it creates a new one.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `conditions`: A keyword list of conditions.
      - `update_params`: A map of attributes to update.
      - `create_params`: A map of attributes to create.
      - `opts`: Options to pass to the repository (default: []).

      ## Examples
          iex> upsert(FatEcto.FatUser, [get_by_clauses: [name: "John Doe"], update_params: %{name: "John Doe Updated"}, create_params: %{name: "John Doe"}])
          {:ok, %FatEcto.FatUser{name: "John Doe Updated"}}
      """
      def upsert(
            schema,
            [get_by_clauses: get_by_clauses, update_params: update_params, create_params: create_params],
            opts \\ []
          ) do
        case get_by(schema, get_by_clauses, opts[:preloads] || []) do
          {:ok, record} -> update(record, schema, update_params, opts)
          {:error, :not_found} -> create(schema, create_params, opts)
        end
      end

      @doc """
      Deletes a record.

      ## Parameters
      - `record`: The record to delete.

      ## Examples
          iex> delete(%FatEcto.FatUser{id: 1})
          {:ok, %FatEcto.FatUser{}}
      """
      def delete(record) do
        @repo.delete(record)
      end

      @doc """
      Deletes all records from the given schema.

      ## Parameters
      - `schema`: The Ecto schema module.

      ## Examples
          iex> delete_all(FatEcto.FatUser)
          {2, nil}
      """
      def delete_all(schema) do
        @repo.delete_all(schema)
      end

      @doc """
      Creates a changeset for the given record and attributes.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `record`: The record to create a changeset for.
      - `attrs`: A map of attributes.

      ## Examples
          iex> changeset(FatEcto.FatUser, %FatEcto.FatUser{}, %{name: "John Doe"})
          #Ecto.Changeset<...>
      """
      def changeset(schema, record, attrs \\ %{}) do
        schema.changeset(record, attrs)
      end

      @doc """
      Retrieves all records that match the given conditions and preloads the specified associations.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `conditions`: A keyword list of conditions.
      - `preloads`: A list of associations to preload (default: []).

      ## Examples
          iex> get_all_by(FatEcto.FatUser, name: "John Doe")
          [%FatEcto.FatUser{name: "John Doe"}]

          iex> get_all_by(FatEcto.FatUser, name: "John Doe", [:posts])
          [%FatEcto.FatUser{name: "John Doe", posts: [%Fat.Post{}]}]
      """
      def get_all_by(schema, conditions, preloads \\ []) do
        schema
        |> where(^conditions)
        |> @repo.all()
        |> @repo.preload(preloads)
      end

      defp has_field?(schema, field) do
        Enum.member?(schema.__schema__(:fields), field) && schema.__schema__(:field_source, field) == field
      end
    end
  end
end
