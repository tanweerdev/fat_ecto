defmodule FatEcto.UpdateRecord do
  @moduledoc false

  defmacro __using__(options) do
    quote do
      alias FatEcto.MacrosHelper
      @repo unquote(options)[:repo]
      @preloads unquote(options)[:preloads]

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
        with {:ok, record} <- MacrosHelper.get_record(id, @repo, @schema) do
          record = MacrosHelper.preload_record(record, @repo, @preloads)
          changeset = @schema.changeset(record, params)
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
              render_record(conn, record, unquote(options) ++ [status_to_put: :ok])
            end
          end
        end
      end

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
          render_resp(conn, "Record soft deleted", 200, put_content_type: "application/json")
        end
      end
    end
  end
end
