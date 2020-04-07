defmodule FatUtils.FatRecord do
  @moduledoc false
  defmacro __using__(options) do
    quote location: :keep do
      @opt_app unquote(options)[:otp_app]
      if !@opt_app do
        raise "please define opt app when using fat query methods"
      end

      @options Keyword.merge(Application.get_env(@opt_app, :fat_ecto) || [], unquote(options))
      @encoder_library @options[:encoder_library]

      if !@encoder_library do
        raise "please define encoder_library when using fat record utils"
      end

      @doc """
        Sanitize the records.
      ### Parameters

        - `record/records`   - List of maps, tuple or a map.

      ### Example

          iex> record = FatEcto.Repo.insert!(%FatEcto.FatDoctor{name: "test", designation: "doctor", phone: "12345", address: "123 Hampton Road"})
          iex> sanitize_map = #{__MODULE__}.sanitize_map(record)
          iex> Map.drop(sanitize_map, [:id])
          %{
              address: "123 Hampton Road",
              designation: "doctor",
              email: nil,
              end_date: nil,
              experience_years: nil,
              name: "test",
              phone: "12345",
              rating: nil,
              start_date: nil
            }

      """
      def sanitize_map(records) when is_list(records) do
        Enum.reduce(records, [], fn rec, acc ->
          acc ++ [sanitize_map(rec)]
        end)
      end

      def sanitize_map(record) when is_tuple(record) do
        case tuple_size(record) do
          2 ->
            [key, value] = Tuple.to_list(record)
            %{key => sanitize_map(value)}

          # TODO: fix this warning
          _size ->
            record
            |> Tuple.to_list()
            |> @encoder_library.Encoder.List.encode([])
        end
      end

      def sanitize_map(record) when is_map(record) do
        schema_keys = [:__struct__, :__meta__]
        # not_loaded_keys = [:__field__, :__owner__, :__cardinality__]

        Enum.reduce(Map.drop(record, schema_keys), %{}, fn {k, v}, acc ->
          cond do
            is_list(v) ->
              values =
                Enum.reduce(v, [], fn rec, acc ->
                  acc ++ [sanitize_map(rec)]
                end)

              Map.put(acc, k, values)

            is_map(v) ->
              case v do
                %Ecto.Association.NotLoaded{} ->
                  acc

                %DateTime{} ->
                  put_value(acc, k, v)

                %Date{} ->
                  put_value(acc, k, v)

                %Time{} ->
                  put_value(acc, k, v)

                %NaiveDateTime{} ->
                  put_value(acc, k, v)

                _v ->
                  Map.put(acc, k, sanitize_map(v))
              end

            is_tuple(v) ->
              Map.put(acc, k, sanitize_map(v))

            true ->
              # Map.put(acc, k, v)
              put_value(acc, k, v)
          end
        end)
      end

      def sanitize_map(record) do
        record
      end

      def put_value(data_map, field, value) do
        Map.put(data_map, field, value)
      end

      defoverridable put_value: 3
    end
  end
end
