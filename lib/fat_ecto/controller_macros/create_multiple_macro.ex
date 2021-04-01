defmodule FatEcto.CreateMultipleRecord do
  @moduledoc false

  @doc "Preprocess params before passing them to changesets"
  @callback pre_process_params_for_multiple_create_method(params :: map(), conn :: Plug.Conn.t()) :: map()

  @doc "Preprocess changesets before inserting records"
  @callback pre_process_changesets_for_multiple_create_method(
              changeset :: Ecto.Changeset.t(),
              conn :: Plug.Conn.t()
            ) ::
              Ecto.Changeset.t()

  @doc "Perform any action on new records after records are created"
  @callback post_create_hook_for_multiple_create_method(records :: list(), conn :: Plug.Conn.t()) :: term()

  @doc "Build multiple changesets"
  @callback build_changesets_for_multiple_create_method(
              params_array_for_records :: list(),
              conn :: Plug.Conn.t()
            ) :: list()

  @doc "Insert multiple changesets"
  @callback insert_records_for_multiple_create_method(changesets :: list) ::
              {:ok, list()} | {:error, term(), Ecto.Changeset.t(), term()}

  defmacro __using__(options \\ []) do
    quote location: :keep do
      @behaviour FatEcto.CreateMultipleRecord
      alias FatEcto.MacrosHelper

      @opt_app unquote(options)[:otp_app]
      @app_level_configs (@opt_app && Application.get_env(@opt_app, FatEcto.CreateMultipleRecord)) || []
      @unquoted_options unquote(options)
      @options Keyword.merge(@app_level_configs, @unquoted_options)

      @preloads @options[:preloads] || []
      @schema @options[:schema]
      @wrapper @options[:wrapper]
      @repo @options[:repo]

      if !@repo do
        raise "please define repo when using create record"
      end

      if !@schema do
        raise "please define schema when using create record"
      end

      if @wrapper in [nil, ""] do
        def create(conn, [] = params) when is_list(params) do
          _create(conn, params)
        end
      else
        def create(conn, %{@wrapper => params}) when is_list(params) do
          _create(conn, params)
        end
      end

      defp _create(conn, params) do
        params = pre_process_params_for_multiple_create_method(params, conn)
        changesets = build_changesets_for_multiple_create_method(params, conn)
        changesets = pre_process_changesets_for_multiple_create_method(changesets, conn)

        # TODO: Support partial insert via options passed
        with {:ok, records} <- insert_records_for_multiple_create_method(changesets) do
          records = MacrosHelper.preload_record(records, @repo, @preloads)
          post_create_hook_for_multiple_create_method(records, conn)
          render_record(conn, records, [status_to_put: :created] ++ @options)
        end
      end

      def build_changesets_for_multiple_create_method(params_array_for_records, _conn) do
        Enum.reduce(params_array_for_records, [], fn params_for_a_record, acc ->
          acc ++ [@schema.changeset(struct(@schema), params_for_a_record)]
        end)
      end

      def insert_records_for_multiple_create_method(changesets) when is_list(changesets) do
        multi =
          Enum.with_index(changesets)
          |> Enum.reduce(Ecto.Multi.new(), fn {cset, index}, multi ->
            Ecto.Multi.insert(multi, index, cset)
          end)

        case @repo.transaction(multi) do
          {:ok, data} ->
            records = Enum.reduce(data, [], fn {_index, record}, acc -> acc ++ [record] end)

            Enum.reduce(records, [], fn record, acc ->
              acc ++ [MacrosHelper.preload_record(record, @repo, @preloads)]
            end)

            {:ok, records}

          {:error, index, changeset, whatever} ->
            # You would need something like below in fallback controller
            # def call(conn, {:error, index, changeset = %Ecto.Changeset{}, _whatever}) do
            #   conn
            #   |> put_status(:unprocessable_entity)
            #   |> put_view(PogioApi.ErrorView)
            #   |> render("errors_with_index.json", %{code: 422, message: "Unprocessable entity", changeset: changeset, index: index})
            # end
            {:error, index, changeset, whatever}
        end
      end

      def pre_process_params_for_multiple_create_method(params, _conn) do
        params
      end

      def pre_process_changesets_for_multiple_create_method(changesets, _conn) do
        changesets
      end

      def post_create_hook_for_multiple_create_method(_records, _conn) do
        "Override if needed"
      end

      defoverridable FatEcto.CreateMultipleRecord
    end
  end
end
