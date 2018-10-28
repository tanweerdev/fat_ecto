defmodule FatEcto.FatQuery.FatAggregate do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      alias FatEcto.FatHelper
      use FatEcto.FatQuery.FatMaximum
      use FatEcto.FatQuery.FatMinimum
      use FatEcto.FatQuery.FatAverage
      use FatEcto.FatQuery.FatCount

      # TODO: Add docs and examples for ex_doc
      # $aggregate: {
      #   "$count" : "score"
      #   "$avg": ["total_marks", "rating"]
      # }
      def build_aggregate(queryable, opts_aggregate) do
        if opts_aggregate == nil do
          queryable
        else
          Enum.reduce(opts_aggregate, queryable, fn {aggregate_type, fields}, queryable ->
            case aggregate_type do
              "$max" ->
                case fields do
                  fields when is_list(fields) ->
                    Enum.reduce(fields, queryable, fn {aggregate_type, field}, queryable ->
                      build_max(queryable, field)
                    end)

                  field when is_binary(field) ->
                    build_max(queryable, field)
                end

              "$min" ->
                case fields do
                  fields when is_list(fields) ->
                    Enum.reduce(fields, queryable, fn {aggregate_type, field}, queryable ->
                      build_min(queryable, field)
                    end)

                  field when is_binary(field) ->
                    build_min(queryable, field)
                end

              "$avg" ->
                case fields do
                  fields when is_list(fields) ->
                    Enum.reduce(fields, queryable, fn {aggregate_type, field}, queryable ->
                      build_avg(queryable, field)
                    end)

                  field when is_binary(field) ->
                    build_avg(queryable, field)
                end

              "$count" ->
                case fields do
                  fields when is_list(fields) ->
                    Enum.reduce(fields, queryable, fn {aggregate_type, field}, queryable ->
                      build_count(queryable, field)
                    end)

                  field when is_binary(field) ->
                    build_count(queryable, field)
                end

              "$count_distinct" ->
                case fields do
                  fields when is_list(fields) ->
                    Enum.reduce(fields, queryable, fn {aggregate_type, field}, queryable ->
                      build_count_distinct(queryable, field)
                    end)

                  field when is_binary(field) ->
                    build_count_distinct(queryable, field)
                end

              "$sum" ->
                case fields do
                  fields when is_list(fields) ->
                    Enum.reduce(fields, queryable, fn {aggregate_type, field}, queryable ->
                      build_sum(queryable, field)
                    end)

                  field when is_binary(field) ->
                    build_sum(queryable, field)
                end
            end
          end)
        end
      end

      def build_max(queryable, field) do
        field = FatHelper.string_to_atom(field)

        from(q in queryable,
          select: merge(q, %{"$aggregate": %{"$max": %{^field => max(field(q, ^field))}}})
        )
      end

      def build_min(queryable, field) do
        field = FatHelper.string_to_atom(field)

        from(q in queryable,
          select: merge(q, %{"$aggregate": %{"$min": %{^field => min(field(q, ^field))}}})
        )
      end

      def build_avg(queryable, field) do
        field = FatHelper.string_to_atom(field)

        from(q in queryable,
          select: merge(q, %{"$aggregate": %{"$avg": %{^field => avg(field(q, ^field))}}})
        )
      end

      def build_count(queryable, field) do
        field = FatHelper.string_to_atom(field)

        from(q in queryable,
          select: merge(q, %{"$aggregate": %{"$count": %{^field => count(field(q, ^field))}}})
        )
      end

      def build_count_distinct(queryable, field) do
        field = FatHelper.string_to_atom(field)

        from(q in queryable,
          select:
            merge(q, %{
              "$aggregate": %{"$count_distinct": %{^field => count(field(q, ^field), :distinct)}}
            })
        )
      end

      def build_sum(queryable, field) do
        field = FatHelper.string_to_atom(field)

        from(q in queryable,
          select: merge(q, %{"$aggregate": %{"$sum": %{^field => sum(field(q, ^field))}}})
        )
      end
    end
  end
end
