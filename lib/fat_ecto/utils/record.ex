defmodule FatUtils.FatRecord do
  defmacro __using__(options) do
    quote location: :keep do
      @moduledoc """
      Record related utils.

      `import` or `alias` it inside your module.
      """

      @opt_app unquote(options)[:otp_app]
      if !@opt_app do
        raise "please define opt app when using fat query methods"
      end

      @options Keyword.merge(Application.get_env(@opt_app, :fat_ecto) || [], unquote(options))
      @encoder_library @options[:encoder_library]

      if !@encoder_library do
        raise "please define encoder_library when using fat record utils"
      end

      # TODO: write tests and docs
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

          _size ->
            record
            |> Tuple.to_list()
            |> @encoder_library.Encoder.List.encode([])
        end
      end

      @doc """
       Takes a map, list of maps, tuple and remove struct field, meta field and not loaded assocations.
      """
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
                  Map.put(acc, k, v)

                %Date{} ->
                  Map.put(acc, k, v)

                %Time{} ->
                  Map.put(acc, k, v)

                %NaiveDateTime{} ->
                  Map.put(acc, k, v)

                _v ->
                  Map.put(acc, k, sanitize_map(v))
              end

            is_tuple(v) ->
              Map.put(acc, k, sanitize_map(v))

            true ->
              Map.put(acc, k, v)
          end
        end)
      end

      def sanitize_map(record) do
        record
      end
    end
  end
end
