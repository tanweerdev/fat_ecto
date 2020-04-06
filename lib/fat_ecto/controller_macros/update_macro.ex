defmodule FatEcto.UpdateRecord do
  @moduledoc false

  defmacro __using__(options) do
    # quote location: :keep do
    quote do
      alias FatEcto.MacrosHelper
      @repo unquote(options)[:repo]
      @preloads unquote(options)[:preloads] || []

      if !@repo do
        raise "please define repo when using create record"
      end

      @schema unquote(options)[:schema]

      if !@schema do
        raise "please define schema when using create record"
      end

      @wrapper unquote(options)[:wrapper]

      if @wrapper in [nil, ""] do
        def update(conn, %{"id" => id} = params) do
          _update(conn, id, params)
        end
      else
        def update(conn, %{"id" => id, "params" => params}) do
          _update(conn, id, params)
        end
      end

      defp _update(conn, id, params) do
        query = process_query_before_fetch_record_for_update(@schema, conn)

        with {:ok, record} <- MacrosHelper.get_record_by_query(:id, id, @repo, query) do
          record = MacrosHelper.preload_record(record, @repo, @preloads)
          params = process_params_before_in_update(params, conn)
          changeset = @schema.changeset(record, params)
          changeset = process_changeset_before_update(changeset, conn)
          # && record.is_active != false if want to disable multiple soft deletion

          soft_delete_key = unquote(options)[:soft_delete_key]
          soft_deleted_value = unquote(options)[:soft_deleted_value]
          # can be used to later undo soft delete
          # not_soft_deleted_value = unquote(options)[:not_soft_deleted_value]

          if soft_delete_key && params[to_string(soft_delete_key)] == soft_deleted_value do
            soft_delete(conn, record, changeset, params, soft_delete_key, soft_deleted_value)
          else
            with {:ok, record} <- @repo.update(changeset) do
              record = MacrosHelper.preload_record(record, @repo, @preloads)
              after_update_hook_for_update(record, conn)
              render_record(conn, record, unquote(options) ++ [status_to_put: :ok])
            end
          end
        end
      end

      # You can use process_params_before_in_update to override params before calling changeset
      def process_params_before_in_update(params, _conn) do
        params
      end

      # You can use process_changeset_before_update to add/update/validate changeset before calling update
      def process_changeset_before_update(changeset, _conn) do
        changeset
      end

      # You can use process_query_before_fetch_record_for_update to override query before fetching record for update
      def process_query_before_fetch_record_for_update(query, _conn) do
        query
      end

      # You can use after_update_hook_for_update to log etc
      def after_update_hook_for_update(_record, _conn) do
        "Override if needed"
      end

      # You can use after_update_hook_for_soft_delete to log etc
      def after_update_hook_for_soft_delete(_record, _conn) do
        "Override if needed"
      end

      defoverridable process_params_before_in_update: 2,
                     process_changeset_before_update: 2,
                     after_update_hook_for_update: 2,
                     after_update_hook_for_soft_delete: 2,
                     process_query_before_fetch_record_for_update: 2

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

        with {:ok, record} <- @repo.update(changeset) do
          record = MacrosHelper.preload_record(record, @repo, @preloads)
          after_update_hook_for_soft_delete(record, conn)
          render_resp(conn, "Record soft deleted", 200, put_content_type: "application/json")
        end
      end
    end
  end
end
