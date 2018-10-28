defmodule FatEcto.FatQuery.FatWhere do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      alias FatEcto.FatQuery.FatDynamics
      # TODO: Add docs and examples for ex_doc
      def build_where(queryable, opts_where, opts \\ []) do
        if opts_where == nil do
          queryable
        else
          # TODO: Add docs and examples of ex_doc for this case here
          Enum.reduce(opts_where, queryable, fn {k, v}, queryable ->
            query_where(queryable, {k, v}, opts)
          end)
        end
      end

      # TODO: Add docs and examples of ex_doc for this case here
      defp query_where(queryable, {k, map_cond}, opts) when is_map(map_cond) do
        queryable =
          case k do
            "$or" ->
              dynamics =
                Enum.reduce(map_cond, false, fn {key, condition}, dynamics ->
                  case condition do
                    %{"$like" => value} ->
                      FatDynamics.like_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                    %{"$ilike" => value} ->
                      FatDynamics.ilike_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                    %{"$lt" => value} ->
                      FatDynamics.lt_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                    %{"$lte" => value} ->
                      FatDynamics.lte_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                    %{"$gt" => value} ->
                      FatDynamics.gt_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                    %{"$gte" => value} ->
                      FatDynamics.gte_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                    condition when not is_list(condition) and not is_map(condition) ->
                      FatDynamics.eq_dynamic(key, condition, dynamics, opts ++ [dynamic_type: :or])

                    _whatever ->
                      dynamics
                  end
                end)

              # TODO: confirm its what should be used `where` or `or_where` below
              from(q in queryable, where: ^dynamics)

            "$not" ->
              queryable

            _whatever ->
              queryable
          end

        dynamics =
          Enum.reduce(map_cond, true, fn {key, value}, dynamics ->
            case key do
              "$like" ->
                FatDynamics.like_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$ilike" ->
                FatDynamics.ilike_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$not_like" ->
                FatDynamics.not_like_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$not_ilike" ->
                FatDynamics.not_ilike_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$lt" ->
                FatDynamics.lt_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$lte" ->
                FatDynamics.lte_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$gt" ->
                FatDynamics.gt_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$gte" ->
                FatDynamics.gte_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$between" ->
                FatDynamics.between_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$not_between" ->
                FatDynamics.not_between_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$in" ->
                FatDynamics.in_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$not_in" ->
                FatDynamics.not_in_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$contains" ->
                FatDynamics.contains_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$contains_any" ->
                FatDynamics.contains_any_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

              "$not" ->
                # TODO:
                # Example
                # "id": {
                # TODO: implement now
                # 	"$not": {
                # 		"$eq": [1,2,3],
                # 		"$gt": 10,
                # 		"$lt": 1
                # 	}
                # }
                # First call the relevent dynamic then not_dynamic
                # e.g id: {"$not": {"$eq": [1,2,3]}
                # First call equal_dynamic with these params and then not_dynamic

                # Example
                # "$not": {
                # 	"id": [
                # 		1,2,3,
                #    ],
                #   "customer_rating": null,
                # 	"$gt": { "id": 10 }
                #  }
                queryable

              "$or" ->
                # TODO:
                # Example
                # "id": {
                # 	"$not": [
                # 		[1,2,3],
                # 		{ "$gt": 10 }
                # 	]
                # }

                # Example
                # "$or": {
                # 	"id": [
                # 		1,2,3,
                #    ],
                # 	"$gt": { "id": 10 }
                #  }
                queryable

              _ ->
                # TODO:
                queryable
            end
          end)

        from(q in queryable, where: ^dynamics)
      end

      # TODO: Add docs and examples of ex_doc for this case here
      # $where: {score == nil}
      defp query_where(queryable, {k, map_cond}, opts) when is_nil(map_cond) do
        from(q in queryable,
          where: ^FatDynamics.is_nil_dynamic(k, true, opts ++ [dynamic_type: :and])
        )
      end

      # TODO: Add docs and examples of ex_doc for this case here
      # TODO: check if following code is needed
      # $where: {score: 5}
      defp query_where(queryable, {k, map_cond}, opts) when not is_list(map_cond) do
        from(q in queryable,
          where: ^FatDynamics.eq_dynamic(k, map_cond, true, opts ++ [dynamic_type: :and])
        )
      end

      # TODO: Add docs and examples of ex_doc for this case here
      # $where: {$not_null: [score, rating]}
      defp query_where(queryable, {k, map_cond}, opts)
           when is_list(map_cond) and k == "$not_null" do
        Enum.reduce(map_cond, queryable, fn key, queryable ->
          from(q in queryable,
            where: ^FatDynamics.not_is_nil_dynamic(key, true, opts ++ [dynamic_type: :and])
          )
        end)
      end

      # TODO: Add docs and examples of ex_doc for this case here
      # $where: {score: $not_null}
      defp query_where(queryable, {k, map_cond}, opts)
           when map_cond == "$not_null" do
        from(q in queryable,
          where: ^FatDynamics.not_is_nil_dynamic(k, true, opts ++ [dynamic_type: :and])
        )
      end
    end
  end
end
