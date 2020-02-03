defmodule FatEcto.DeleteRecord do
  @moduledoc false

  defmacro __using__(options) do
    quote do
      alias FatEcto.MacrosHelper

      @repo unquote(options)[:repo]
      if !@repo do
        raise "please define repo when using delete record"
      end

      @schema unquote(options)[:schema]
      if !@schema do
        raise "please define schema when using delete record"
      end

      def delete(conn, %{"id" => id}) do
        case MacrosHelper.get_record(id, @repo, @schema) do
          {:error, :not_found} ->
            error_view_module = unquote(options)[:error_view_module]
            error_view = unquote(options)[:error_view_404]
            data_to_view_as = unquote(options)[:error_data_to_view_as]

            render_record(
              conn,
              "Record not found",
              unquote(options) ++
                [
                  status_to_put: 404,
                  put_view_module: error_view_module,
                  view_to_render: error_view,
                  data_to_view_as: data_to_view_as
                ]
            )

          {:ok, record} ->
            data = add_assoc_constraint(record, id)

            case @repo.delete(data) do
              {:ok, _struct} ->
                render_resp(conn, "Record Deleted", 204, put_content_type: "application/json")

              {:error, changeset} ->
                error_view = unquote(options)[:error_view]
                errors_changeset(conn, changeset, status_to_put: 422, put_view_module: error_view)
            end
        end
      end

      def add_assoc_constraint(record, id) do
        foreign_keys = unquote(options)[:foreign_keys]
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
    end
  end
end
