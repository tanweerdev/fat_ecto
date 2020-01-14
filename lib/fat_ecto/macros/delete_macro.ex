defmodule FatEcto.DeleteRecord do
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
            not_found(conn, "Record not found")

          {:ok, record} ->
            data = add_assoc_constraint(record, id)

            case @repo.delete(data) do
              {:ok, _struct} ->
                render_resp(conn, "Record Deleted", 204, put_content_type: "application/json")

              {:error, changeset} ->
                changeset_errors(conn, changeset)
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
