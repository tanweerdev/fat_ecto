defmodule FatUtils.FatRecord do
  @moduledoc false
  defmacro __using__(options) do
    quote location: :keep do
      @options FatEcto.FatHelper.get_module_options(unquote(options), FatUtils.FatRecord)

      @encoder_library @options[:encoder_library]

      if !@encoder_library do
        raise "please define encoder_library when using fat record utils"
      end

      # TODO: Add a jason library configuration support
      # @doc """
      # Returns the configured JSON encoding library for FatUtils.FatRecord.
      # To customize the JSON library, including the following
      # in your `config/config.exs`:
      #     config :phoenix, :json_library, Jason
      # """
      # def json_library do
      #   Application.get_env(:phoenix, :json_library, Jason)
      # end

      @doc """
        Sanitize the records.
      ### Parameters

        - `record/records`   - List of maps, tuple or a map.

      ### Example

          iex> record = FatEcto.Repo.insert!(%FatEcto.FatDoctor{name: "test", designation: "doctor", phone: "12345", address: "123 Hampton Road"})
          iex> sanitized = #{__MODULE__}.sanitize(record)
          iex> Map.drop(sanitized, [:id])
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
      def sanitize(records) when is_list(records) do
        sanitize_list(records)
      end

      def sanitize(record) when is_tuple(record) do
        sanitize_tuple(record)
      end

      def sanitize(record) when is_map(record) do
        sanitize_map(record)
      end

      def sanitize(record) do
        record
      end

      def sanitize_list(records) when is_list(records) do
        Enum.reduce(records, [], fn rec, acc ->
          acc ++ [sanitize(rec)]
        end)
      end

      def sanitize_tuple(record) when is_tuple(record) do
        case tuple_size(record) do
          2 ->
            [key, value] = Tuple.to_list(record)
            %{key => sanitize(value)}

          # TODO: fix this warning
          _size ->
            record
            |> Tuple.to_list()
            |> @encoder_library.Encoder.List.encode([])
        end
      end

      def sanitize_map(record) when is_map(record) do
        {rec, condition} = custom_map?(record)

        if condition do
          rec
        else
          sanitize_map_iteratively(record)
        end
      end

      def sanitize_map_iteratively(record, opts \\ []) when is_map(record) do
        schema_keys = [:__struct__, :__meta__]

        # not_loaded_keys = [:__field__, :__owner__, :__cardinality__]

        Enum.reduce(Map.drop(record, schema_keys), %{}, fn {k, v}, acc ->
          cond do
            opts[:only] && k not in opts[:only] ->
              acc

            opts[:except] && k in opts[:except] ->
              acc

            is_list(v) ->
              values =
                Enum.reduce(v, [], fn rec, acc ->
                  acc ++ [sanitize(rec)]
                end)

              Map.put(acc, k, values)

            is_map(v) ->
              put_map_value_conditionally(acc, k, v)

            is_tuple(v) ->
              Map.put(acc, k, sanitize(v))

            true ->
              put_value(acc, k, v)
          end
        end)
      end

      def custom_map?(record) do
        {record, false}
      end

      def put_map_value_conditionally(data_map, field, value) do
        case value do
          %Ecto.Association.NotLoaded{} ->
            data_map

          %DateTime{} ->
            put_value(data_map, field, value)

          %Date{} ->
            put_value(data_map, field, value)

          %Time{} ->
            put_value(data_map, field, value)

          %NaiveDateTime{} ->
            put_value(data_map, field, value)

          _v ->
            Map.put(data_map, field, sanitize(value))
        end
      end

      def put_value(data_map, field, value) do
        Map.put(data_map, field, value)
      end

      defoverridable put_value: 3,
                     put_map_value_conditionally: 3,
                     sanitize_map: 1,
                     sanitize_map_iteratively: 1,
                     sanitize_tuple: 1,
                     sanitize_list: 1,
                     custom_map?: 1
    end
  end
end
