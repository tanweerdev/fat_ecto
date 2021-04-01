defmodule FatEcto.UpdateRecord do
  @moduledoc false
  @doc "Preprocess changeset before update record"
  @callback pre_process_changeset_for_update_method(
              changeset :: Ecto.Changeset.t(),
              params :: map(),
              conn :: Plug.Conn.t()
            ) :: Ecto.Changeset.t()

  @doc "Preprocess params before passing them to changeset"
  @callback pre_process_params_for_update_method(params :: map(), conn :: Plug.Conn.t()) :: map()

  @doc "Perform any action on old or updated record after record is updated"
  @callback post_update_hook_for_update_method(
              record :: struct(),
              record_before_update :: struct(),
              params :: map(),
              conn :: Plug.Conn.t()
            ) :: term()

  @doc "Perform any action on old or updates record after soft deletion"
  @callback post_update_hook_for_soft_delete_method(
              record :: struct(),
              record_before_update :: struct(),
              params :: map(),
              conn :: Plug.Conn.t()
            ) :: term()

  @doc "Update a query before sending it in the fetch method. By default the query is name of your schema"
  @callback pre_process_fetch_query_for_update_method(
              query :: Ecto.Query.t(),
              params :: map(),
              conn :: Plug.Conn.t()
            ) :: Ecto.Query.t()

  defmacro __using__(options \\ []) do
    quote location: :keep do
      @behaviour FatEcto.UpdateRecord
      alias FatEcto.MacrosHelper

      @opt_app unquote(options)[:otp_app]
      @app_level_configs (@opt_app && Application.get_env(@opt_app, FatEcto.UpdateRecord)) || []
      @unquoted_options unquote(options)
      @options Keyword.merge(@app_level_configs, @unquoted_options)

      @preloads @options[:preloads] || []
      @schema @options[:schema]
      @custom_changeset @options[:custom_changeset]
      @wrapper @options[:wrapper]
      @get_by_unqiue_field @options[:get_by_unqiue_field]
      @repo @options[:repo]

      if !@repo do
        raise "please define repo when using create record"
      end

      if !@schema do
        raise "please define schema when using create record"
      end

      case {@wrapper in [nil, ""], @get_by_unqiue_field in [nil, ""]} do
        {true, true} ->
          def update(conn, %{"id" => id} = params) do
            _update(conn, %{"key" => :id, "value" => id}, params)
          end

        {true, false} ->
          def update(conn, %{@get_by_unqiue_field => value} = params) do
            _update(conn, %{"key" => @get_by_unqiue_field, "value" => value}, params)
          end

        {false, true} ->
          def update(conn, %{"id" => id, @wrapper => params}) do
            _update(conn, %{"key" => :id, "value" => id}, params)
          end

        {false, false} ->
          def update(conn, %{@get_by_unqiue_field => value, @wrapper => params}) do
            _update(conn, %{"key" => @get_by_unqiue_field, "value" => value}, params)
          end
      end

      defp _update(conn, %{"key" => key, "value" => value}, params) do
        query = pre_process_fetch_query_for_update_method(@schema, params, conn)

        with {:ok, record} <- MacrosHelper.get_record_by_query(key, value, @repo, query) do
          soft_delete_key = @options[:soft_delete_key]
          soft_deleted_value = @options[:soft_deleted_value]

          if soft_delete_key && params[to_string(soft_delete_key)] == soft_deleted_value do
            soft_delete(
              conn,
              record,
              @schema.changeset(record, %{soft_delete_key => soft_deleted_value}),
              params,
              soft_delete_key,
              soft_deleted_value
            )
          else
            case check_if_record_soft_deleted?(record, soft_delete_key, soft_deleted_value) do
              true ->
                error_view_module = @options[:error_view_module]
                error_view = @options[:error_view_403]
                data_to_view_as = @options[:error_data_to_view_as]

                render_record(
                  conn,
                  "Update on soft deleted record is not allowed",
                  [
                    status_to_put: 403,
                    put_view_module: error_view_module,
                    view_to_render: error_view,
                    data_to_view_as: data_to_view_as
                  ] ++ @options
                )

              false ->
                record_before_update = MacrosHelper.preload_record(record, @repo, @preloads)
                params = pre_process_params_for_update_method(params, conn)
                changeset = build_update_changeset(@custom_changeset, record_before_update, params)

                changeset = pre_process_changeset_for_update_method(changeset, params, conn)

                with {:ok, record} <- @repo.update(changeset) do
                  record = MacrosHelper.preload_record(record, @repo, @preloads)
                  post_update_hook_for_update_method(record, record_before_update, params, conn)
                  render_record(conn, record, [status_to_put: :ok] ++ @options)
                end
            end
          end

          # && record.is_active != false if want to disable multiple soft deletion

          # can be used to later undo soft delete
          # not_soft_deleted_value = @options[:not_soft_deleted_value]
        end
      end

      def pre_process_params_for_update_method(params, _conn) do
        params
      end

      def pre_process_changeset_for_update_method(changeset, _params, _conn) do
        changeset
      end

      def pre_process_fetch_query_for_update_method(query, _params, _conn) do
        query
      end

      def post_update_hook_for_update_method(_record, _record_before_update, _params, _conn) do
        "Override if needed"
      end

      def post_update_hook_for_soft_delete_method(_record, _record_before_update, _params, _conn) do
        "Override if needed"
      end

      defp build_update_changeset(cs, record, params) when is_nil(cs), do: @schema.changeset(record, params)

      defp build_update_changeset(cs, record, params) when is_function(cs, 2) do
        cs.(record, params)
      end

      defp build_update_changeset(cs, _record, _params), do: cs

      def check_if_record_soft_deleted?(_record, soft_delete_key, _soft_deleted_value)
          when is_nil(soft_delete_key),
          do: false

      def check_if_record_soft_deleted?(record, soft_delete_key, soft_deleted_value) do
        if Map.has_key?(record, soft_delete_key) && Map.get(record, soft_delete_key) == soft_deleted_value do
          true
        else
          false
        end
      end

      defoverridable FatEcto.UpdateRecord

      # TODO: util functions
      # TODO: it only soft delete one level
      def soft_delete(conn, record, changeset, params, soft_delete_key, soft_deleted_value) do
        record =
          Enum.reduce(FatEcto.AssocModel.has_only(@schema), record, fn association, record ->
            if Map.has_key?(struct(association.related), soft_delete_key) do
              @repo.preload(record, [association.field])
            else
              record
            end
          end)

        params_map =
          Enum.reduce(FatEcto.AssocModel.has_only(@schema), changeset.changes, fn association, params_map ->
            if Map.has_key?(struct(association.related), soft_delete_key) do
              assoc_records = Map.get(record, association.field)

              assoc_map =
                Enum.map(assoc_records, fn record ->
                  %{:id => record.id, soft_delete_key => soft_deleted_value}
                end)

              Map.put(params_map, association.field, assoc_map)
            else
              params_map
            end
          end)

        changeset = @schema.changeset(record, params_map)

        changeset =
          Enum.reduce(FatEcto.AssocModel.has_only(@schema), changeset, fn association, changeset ->
            if Map.has_key?(struct(association.related), soft_delete_key) do
              changeset |> Ecto.Changeset.cast_assoc(association.field)
            else
              changeset
            end
          end)

        with {:ok, record_after_update} <- @repo.update(changeset) do
          record_after_update = MacrosHelper.preload_record(record_after_update, @repo, @preloads)
          post_update_hook_for_soft_delete_method(record_after_update, record, params, conn)
          render_resp(conn, "Record soft deleted", 200, put_content_type: "application/json")
        end
      end
    end
  end
end
