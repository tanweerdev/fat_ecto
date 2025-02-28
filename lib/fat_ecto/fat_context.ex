defmodule FatEcto.FatContext do
  @moduledoc """
  Provides a set of utility functions to simplify common Ecto operations such as querying, creating, updating, and deleting records.

  This module is designed to be used within a context module to provide a consistent and easy-to-use API for interacting with your database.

  ## Usage

      defmodule FatEcto.FatAppContext do
        use FatEcto.FatContext, repo: FatEcto.Repo

        # Custom functions can be added here
      end

  Now you can use the functions provided by `FatEcto.FatContext` within `FatEcto.FatAppContext`.
  """

  defmacro __using__(options \\ []) do
    quote location: :keep do
      @options unquote(options)
      @repo @options[:repo] || raise("Please define :repo when using FatEcto.FatContext")
      def repo_option, do: @repo

      # Defer the repo check to runtime
      @after_compile FatEcto.FatContext

      import Ecto.Query, warn: false

      @doc """
      Retrieves the first record from the given schema.

      ## Parameters
      - `schema`: The Ecto schema module.
      - `preloads`: A list of associations to preload (default: []).

      ## Examples

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.first(FatHospital)
          %FatEcto.FatHospital{}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.first(FatHospital, [:fat_rooms])
          %FatEcto.FatHospital{fat_rooms: [%FatEcto.FatRoom{}]}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.last(FatHospital)
          %FatEcto.FatHospital{}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.last(FatHospital, [:fat_rooms])
          %FatEcto.FatHospital{fat_rooms: [%FatEcto.FatRoom{}]}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.count(FatHospital)
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.count(FatHospital, name: "John Doe")
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.list(FatHospital)
          [%FatEcto.FatHospital{}, %FatEcto.FatHospital{}]

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.list(FatHospital, [:fat_rooms])
          [%FatEcto.FatHospital{fat_rooms: [%FatEcto.FatRoom{}]}, %FatEcto.FatHospital{fat_rooms: []}]
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.list_by(FatHospital, name: "John Doe")
          [%FatEcto.FatHospital{name: "John Doe"}]

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.list_by(FatHospital, name: "John Doe", [:fat_rooms])
          [%FatEcto.FatHospital{name: "John Doe", fat_rooms: [%FatEcto.FatRoom{}]}]
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get!(FatHospital, 1)
          %FatEcto.FatHospital{id: 1}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get!(FatHospital, 999)
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get(FatHospital, 1)
          {:ok, %FatEcto.FatHospital{id: 1}}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get(FatHospital, 999)
          {:error, :not_found}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get(FatHospital, 1, [:fat_rooms])
          {:ok, %FatEcto.FatHospital{id: 1, fat_rooms: [%FatEcto.FatRoom{}]}}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get_by(FatHospital, name: "John Doe")
          {:ok, %FatEcto.FatHospital{name: "John Doe"}}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get_by(FatHospital, name: "Non-existent")
          {:error, :not_found}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get_by(FatHospital, name: "John Doe", [:fat_rooms])
          {:ok, %FatEcto.FatHospital{name: "John Doe", fat_rooms: [%FatEcto.FatRoom{}]}}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.create(FatHospital, %{name: "John Doe"})
          {:ok, %FatEcto.FatHospital{name: "John Doe"}}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.create(FatHospital, %{name: "John Doe"}, [returning: true])
          {:ok, %FatEcto.FatHospital{name: "John Doe"}}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.create_by(%FatHospital{}, &FatHospital.changeset/2, %{name: "John Doe"})
          {:ok, %FatEcto.FatHospital{name: "John Doe"}}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.create!(FatHospital, %{name: "John Doe"})
          %FatEcto.FatHospital{name: "John Doe"}

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.create!(FatHospital, %{name: nil})
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.create_by!(%FatHospital{}, &FatHospital.changeset/2, %{name: "John Doe"})
          %FatEcto.FatHospital{name: "John Doe"}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.update_by(%FatHospital{name: "Old Name"}, &FatHospital.changeset/2, %{name: "New Name"})
          {:ok, %FatEcto.FatHospital{name: "New Name"}}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.update(%FatHospital{name: "Old Name"}, FatHospital, %{name: "New Name"})
          {:ok, %FatEcto.FatHospital{name: "New Name"}}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.update_by!(%FatHospital{name: "Old Name"}, &FatHospital.changeset/2, %{name: "New Name"})
          %FatEcto.FatHospital{name: "New Name"}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.update!(%FatHospital{name: "Old Name"}, FatHospital, %{name: "New Name"})
          %FatEcto.FatHospital{name: "New Name"}
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.upsert(FatHospital, [name: "John Doe"], %{name: "John Doe Updated"}, %{name: "John Doe"})
          {:ok, %FatEcto.FatHospital{name: "John Doe Updated"}}
      """
      def upsert(schema, conditions, update_params, create_params, opts \\ []) do
        case get_by(schema, conditions) do
          {:ok, record} -> update(record, schema, update_params, opts)
          {:error, :not_found} -> create(schema, create_params, opts)
        end
      end

      @doc """
      Deletes a record.

      ## Parameters
      - `record`: The record to delete.

      ## Examples

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.delete(%FatHospital{id: 1})
          {:ok, %FatEcto.FatHospital{}}
      """
      def delete(record) do
        @repo.delete(record)
      end

      @doc """
      Deletes all records from the given schema.

      ## Parameters
      - `schema`: The Ecto schema module.

      ## Examples

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.delete_all(FatHospital)
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.changeset(FatHospital, %FatHospital{}, %{name: "John Doe"})
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

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get_all_by(FatHospital, name: "John Doe")
          [%FatEcto.FatHospital{name: "John Doe"}]

          iex> alias FatEcto.FatHospital
          iex> FatEcto.FatAppContext.get_all_by(FatHospital, name: "John Doe", [:fat_rooms])
          [%FatEcto.FatHospital{name: "John Doe", fat_rooms: [%FatEcto.FatRoom{}]}]
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

  @doc """
  Callback function that runs after the module is compiled.
  """
  @spec __after_compile__(%{:module => atom()}, any()) :: nil
  def __after_compile__(%{module: module}, _bytecode) do
    repo = module.repo_option()

    unless FatEcto.FatHelper.implements_behaviour?(repo, Ecto.Repo) do
      raise ArgumentError, """
      The provided :repo option is not a valid Ecto.Repo.
      Expected a module that implements the Ecto.Repo behaviour, got: #{inspect(repo)}
      """
    end
  end
end
