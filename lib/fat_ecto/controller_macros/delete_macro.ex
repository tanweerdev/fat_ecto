defmodule FatEcto.DeleteRecord do
  @moduledoc false
  @doc "Update a query before sending it in the fetch method. By default the query is name of your schema"
  @callback pre_process_fetch_query_for_delete_method(query :: Ecto.Query.t(), conn :: Plug.Conn.t()) ::
              Ecto.Query.t()

  @doc "Perform any action after deletion"
  @callback post_delete_hook_for_delete_method(record :: struct(), conn :: Plug.Conn.t()) :: term()

  defmacro __using__(options \\ []) do
    quote location: :keep do
      @behaviour FatEcto.DeleteRecord
      alias FatEcto.MacrosHelper

      @opt_app unquote(options)[:otp_app]
      @app_level_configs (@opt_app && Application.get_env(@opt_app, FatEcto.DeleteRecord)) || []
      @unquoted_options unquote(options)
      @options Keyword.merge(@app_level_configs, @unquoted_options)

      @repo @options[:repo]
      @status_to_put @options[:status_to_put]
      # You can disable add_assoc_constraint by passing add_assoc_constraint value false
      @add_assoc_constraint @options[:add_assoc_constraint]
      @get_by_unqiue_field @options[:get_by_unqiue_field]
      @schema @options[:schema]

      if !@repo do
        raise "please define repo when using delete record"
      end

      if !@schema do
        raise "please define schema when using delete record"
      end

      if @get_by_unqiue_field in [nil, ""] do
        def delete(conn, %{"id" => id}) do
          _delete(conn, %{"key" => :id, "value" => id})
        end
      else
        def delete(conn, %{@get_by_unqiue_field => value}) do
          _delete(conn, %{"key" => @get_by_unqiue_field, "value" => value})
        end
      end

      # TODO: Lets implement with in these macros and add sample fallback controller
      # then we will be independent of few options eg we dont have to render error
      defp _delete(conn, %{"key" => key, "value" => value}) do
        query = pre_process_fetch_query_for_delete_method(@schema, conn)

        case MacrosHelper.get_record_by_query(key, value, @repo, query) do
          {:error, :not_found} ->
            error_view_module = @options[:error_view_module]
            error_view = @options[:error_view_404]
            data_to_view_as = @options[:error_data_to_view_as]

            render_record(
              conn,
              "Record not found",
              [
                status_to_put: 404,
                put_view_module: error_view_module,
                view_to_render: error_view,
                data_to_view_as: data_to_view_as
              ] ++ @options
            )

          {:ok, record} ->
            record =
              if @add_assoc_constraint == false do
                record
              else
                add_assoc_constraint(record, value)
              end

            case @repo.delete(record) do
              {:ok, _struct} ->
                post_delete_hook_for_delete_method(record, conn)

                if @status_to_put do
                  render_resp(conn, "Record Deleted", @status_to_put, put_content_type: "application/json")
                else
                  render_resp(conn, "Record Deleted", 200, put_content_type: "application/json")
                end

              {:error, changeset} ->
                error_view = @options[:error_view]
                errors_changeset(conn, changeset, status_to_put: 422, put_view_module: error_view)
            end
        end
      end

      def pre_process_fetch_query_for_delete_method(query, _conn) do
        query
      end

      def post_delete_hook_for_delete_method(_record, _conn) do
        "Override if needed"
      end

      def add_assoc_constraint(record, id) do
        foreign_keys = @options[:foreign_keys]
        associations = FatEcto.AssocModel.has_and_many_to_many(@schema)
        table_name = @schema |> to_string() |> String.split(".") |> List.last() |> String.downcase()

        Enum.reduce(associations, Ecto.Changeset.change(record), fn association, cs ->
          case association do
            %Ecto.Association.Has{} ->
              Ecto.Changeset.no_assoc_constraint(cs, association.field,
                message: "are still associated with #{table_name}_id: #{id}"
              )

            %Ecto.Association.ManyToMany{} ->
              if is_map(foreign_keys) && foreign_keys[association.field] do
                Ecto.Changeset.foreign_key_constraint(cs, association.field,
                  name: foreign_keys[association.field],
                  message: "are still associated with #{table_name}_id: #{id}"
                )
              else
                cs
              end

            _ ->
              cs
          end
        end)
      end

      defoverridable FatEcto.DeleteRecord
    end
  end
end
