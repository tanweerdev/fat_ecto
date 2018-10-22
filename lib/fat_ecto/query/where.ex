defmodule FatEcto.FatQuery.FatWhere do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
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
                      # query = from q in CustomerModel, where: like(fragment("(?)::TEXT", q.id), "%1")
                      if opts[:binding] == :last do
                        dynamic(
                          [..., c],
                          like(
                            fragment("(?)::TEXT", field(c, ^String.to_existing_atom(key))),
                            ^value
                          ) or ^dynamics
                        )
                      else
                        dynamic(
                          [q],
                          like(
                            fragment("(?)::TEXT", field(q, ^String.to_existing_atom(key))),
                            ^value
                          ) or ^dynamics
                        )
                      end

                    %{"$ilike" => value} ->
                      if opts[:binding] == :last do
                        dynamic(
                          [..., c],
                          ilike(
                            fragment("(?)::TEXT", field(c, ^String.to_existing_atom(key))),
                            ^value
                          ) or ^dynamics
                        )
                      else
                        dynamic(
                          [q],
                          ilike(
                            fragment("(?)::TEXT", field(q, ^String.to_existing_atom(key))),
                            ^value
                          ) or ^dynamics
                        )
                      end

                    %{"$lt" => value} ->
                      if opts[:binding] == :last do
                        if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                          value = String.replace(value, "$", "", global: false)

                          dynamic(
                            [..., c],
                            field(c, ^String.to_existing_atom(key)) <
                              field(c, ^String.to_existing_atom(value)) or ^dynamics
                          )
                        else
                          dynamic(
                            [..., c],
                            field(c, ^String.to_existing_atom(key)) < ^value or ^dynamics
                          )
                        end
                      else
                        if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                          value = String.replace(value, "$", "", global: false)

                          dynamic(
                            [q],
                            field(q, ^String.to_existing_atom(key)) <
                              field(q, ^String.to_existing_atom(value)) or ^dynamics
                          )
                        else
                          dynamic(
                            [q],
                            field(q, ^String.to_existing_atom(key)) < ^value or ^dynamics
                          )
                        end
                      end

                    %{"$lte" => value} ->
                      if opts[:binding] == :last do
                        if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                          value = String.replace(value, "$", "", global: false)

                          dynamic(
                            [..., c],
                            field(c, ^String.to_existing_atom(key)) <=
                              field(c, ^String.to_existing_atom(value)) or ^dynamics
                          )
                        else
                          from(
                            [..., c] in queryable,
                            where: field(c, ^String.to_existing_atom(key)) <= ^value
                          )
                        end
                      else
                        if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                          value = String.replace(value, "$", "", global: false)

                          dynamic(
                            [q],
                            field(q, ^String.to_existing_atom(key)) <=
                              field(q, ^String.to_existing_atom(value)) or ^dynamics
                          )
                        else
                          from(
                            q in queryable,
                            where: field(q, ^String.to_existing_atom(key)) <= ^value
                          )
                        end
                      end

                    %{"$gt" => value} ->
                      if opts[:binding] == :last do
                        if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                          value = String.replace(value, "$", "", global: false)

                          dynamic(
                            [..., c],
                            field(c, ^String.to_existing_atom(key)) >
                              field(c, ^String.to_existing_atom(value)) or ^dynamics
                          )
                        else
                          dynamic(
                            [..., c],
                            field(c, ^String.to_existing_atom(key)) > ^value or ^dynamics
                          )
                        end
                      else
                        if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                          value = String.replace(value, "$", "", global: false)

                          dynamic(
                            [q],
                            field(q, ^String.to_existing_atom(key)) >
                              field(q, ^String.to_existing_atom(value)) or ^dynamics
                          )
                        else
                          dynamic(
                            [q],
                            field(q, ^String.to_existing_atom(key)) > ^value or ^dynamics
                          )
                        end
                      end

                    %{"$gte" => value} ->
                      if opts[:binding] == :last do
                        if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                          value = String.replace(value, "$", "", global: false)

                          dynamic(
                            [..., c],
                            field(c, ^String.to_existing_atom(key)) >=
                              field(c, ^String.to_existing_atom(value)) or ^dynamics
                          )
                        else
                          dynamic(
                            [..., c],
                            field(c, ^String.to_existing_atom(key)) >= ^value or ^dynamics
                          )
                        end
                      else
                        if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                          value = String.replace(value, "$", "", global: false)

                          dynamic(
                            [q],
                            field(q, ^String.to_existing_atom(key)) >=
                              field(q, ^String.to_existing_atom(value)) or ^dynamics
                          )
                        else
                          dynamic(
                            [q],
                            field(q, ^String.to_existing_atom(key)) >= ^value or ^dynamics
                          )
                        end
                      end

                    condition when not is_list(condition) and not is_map(condition) ->
                      if opts[:binding] == :last do
                        dynamic(
                          [..., c],
                          field(c, ^String.to_existing_atom(key)) == ^condition or ^dynamics
                        )
                      else
                        dynamic(
                          [q],
                          field(q, ^String.to_existing_atom(key)) == ^condition or ^dynamics
                        )
                      end

                    _whatever ->
                      dynamics
                  end
                end)

              from(q in queryable, where: ^dynamics)

            "$not" ->
              queryable

            _whatever ->
              queryable
          end

        Enum.reduce(map_cond, queryable, fn {key, value}, queryable ->
          case key do
            "$like" ->
              if opts[:binding] == :last do
                from([..., c] in queryable,
                  where: like(field(c, ^String.to_existing_atom(k)), ^value)
                )
              else
                from(q in queryable, where: like(field(q, ^String.to_existing_atom(k)), ^value))
              end

            "$ilike" ->
              if opts[:binding] == :last do
                from([..., c] in queryable,
                  where: ilike(field(c, ^String.to_existing_atom(k)), ^value)
                )
              else
                from(q in queryable, where: ilike(field(q, ^String.to_existing_atom(k)), ^value))
              end

            "$notlike" ->
              if opts[:binding] == :last do
                from([..., c] in queryable,
                  where: not like(field(c, ^String.to_existing_atom(k)), ^value)
                )
              else
                from(q in queryable, where: not like(field(q, ^String.to_existing_atom(k)), ^value))
              end

            "$notilike" ->
              if opts[:binding] == :last do
                from(
                  [..., c] in queryable,
                  where: not ilike(field(c, ^String.to_existing_atom(k)), ^value)
                )
              else
                from(
                  q in queryable,
                  where: not ilike(field(q, ^String.to_existing_atom(k)), ^value)
                )
              end

            "$lt" ->
              if opts[:binding] == :last do
                if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                  value = String.replace(value, "$", "", global: false)

                  from(
                    [..., c] in queryable,
                    where:
                      field(c, ^String.to_existing_atom(k)) <
                        field(c, ^String.to_existing_atom(value))
                  )
                else
                  from([..., c] in queryable, where: field(c, ^String.to_existing_atom(k)) < ^value)
                end
              else
                if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                  value = String.replace(value, "$", "", global: false)

                  from(
                    q in queryable,
                    where:
                      field(q, ^String.to_existing_atom(k)) <
                        field(q, ^String.to_existing_atom(value))
                  )
                else
                  from(q in queryable, where: field(q, ^String.to_existing_atom(k)) < ^value)
                end
              end

            "$lte" ->
              if opts[:binding] == :last do
                if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                  value = String.replace(value, "$", "", global: false)

                  from(
                    [..., c] in queryable,
                    where:
                      field(c, ^String.to_existing_atom(k)) <=
                        field(c, ^String.to_existing_atom(value))
                  )
                else
                  from([..., c] in queryable, where: field(c, ^String.to_existing_atom(k)) <= ^value)
                end
              else
                if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                  value = String.replace(value, "$", "", global: false)

                  from(
                    q in queryable,
                    where:
                      field(q, ^String.to_existing_atom(k)) <=
                        field(q, ^String.to_existing_atom(value))
                  )
                else
                  from(q in queryable, where: field(q, ^String.to_existing_atom(k)) <= ^value)
                end
              end

            "$gt" ->
              if opts[:binding] == :last do
                if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                  value = String.replace(value, "$", "", global: false)

                  from(
                    [..., c] in queryable,
                    where:
                      field(c, ^String.to_existing_atom(k)) >
                        field(c, ^String.to_existing_atom(value))
                  )
                else
                  from([..., c] in queryable, where: field(c, ^String.to_existing_atom(k)) > ^value)
                end
              else
                if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                  value = String.replace(value, "$", "", global: false)

                  from(
                    q in queryable,
                    where:
                      field(q, ^String.to_existing_atom(k)) >
                        field(q, ^String.to_existing_atom(value))
                  )
                else
                  from(q in queryable, where: field(q, ^String.to_existing_atom(k)) > ^value)
                end
              end

            "$gte" ->
              if opts[:binding] == :last do
                if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                  value = String.replace(value, "$", "", global: false)

                  from(
                    [..., c] in queryable,
                    where:
                      field(c, ^String.to_existing_atom(k)) >=
                        field(c, ^String.to_existing_atom(value))
                  )
                else
                  from([..., c] in queryable, where: field(c, ^String.to_existing_atom(k)) >= ^value)
                end
              else
                if FatEcto.FatHelper.is_fat_ecto_field?(value) do
                  value = String.replace(value, "$", "", global: false)

                  from(
                    q in queryable,
                    where:
                      field(q, ^String.to_existing_atom(k)) >=
                        field(q, ^String.to_existing_atom(value))
                  )
                else
                  from(q in queryable, where: field(q, ^String.to_existing_atom(k)) >= ^value)
                end
              end

            "$between" ->
              if opts[:binding] == :last do
                from(
                  [..., c] in queryable,
                  where:
                    field(c, ^String.to_existing_atom(k)) > ^Enum.min(value) and
                      field(c, ^String.to_existing_atom(k)) < ^Enum.max(value)
                )
              else
                from(
                  q in queryable,
                  where:
                    field(q, ^String.to_existing_atom(k)) > ^Enum.min(value) and
                      field(q, ^String.to_existing_atom(k)) < ^Enum.max(value)
                )
              end

            "$notbetween" ->
              if opts[:binding] == :last do
                from(
                  [..., c] in queryable,
                  where:
                    field(c, ^String.to_existing_atom(k)) < ^Enum.min(value) or
                      field(c, ^String.to_existing_atom(k)) > ^Enum.max(value)
                )
              else
                from(
                  q in queryable,
                  where:
                    field(q, ^String.to_existing_atom(k)) < ^Enum.min(value) or
                      field(q, ^String.to_existing_atom(k)) > ^Enum.max(value)
                )
              end

            "$in" ->
              if opts[:binding] == :last do
                from([..., c] in queryable, where: field(c, ^String.to_existing_atom(k)) in ^value)
              else
                from(q in queryable, where: field(q, ^String.to_existing_atom(k)) in ^value)
              end

            "$notin" ->
              if opts[:binding] == :last do
                from([..., c] in queryable,
                  where: field(c, ^String.to_existing_atom(k)) not in ^value
                )
              else
                from(q in queryable, where: field(q, ^String.to_existing_atom(k)) not in ^value)
              end

            "$contains" ->
              # value = Enum.join(value, " ")
              # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

              if opts[:binding] == :last do
                from(
                  [..., c] in queryable,
                  where: fragment("? @> ?", field(c, ^String.to_existing_atom(k)), ^value)
                )
              else
                from(
                  q in queryable,
                  where: fragment("? @> ?", field(q, ^String.to_existing_atom(k)), ^value)
                )
              end

            "$contains_any" ->
              if opts[:binding] == :last do
                from(
                  [..., c] in queryable,
                  where: fragment("? && ?", field(c, ^String.to_existing_atom(k)), ^value)
                )
              else
                from(
                  q in queryable,
                  where: fragment("? && ?", field(q, ^String.to_existing_atom(k)), ^value)
                )
              end

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
      end

      # TODO: Add docs and examples of ex_doc for this case here
      defp query_where(queryable, {k, map_cond}, opts) when is_nil(map_cond) do
        if opts[:binding] == :last do
          from([..., c] in queryable, where: is_nil(field(c, ^String.to_existing_atom(k))))
        else
          from(q in queryable, where: is_nil(field(q, ^String.to_existing_atom(k))))
        end
      end

      # TODO: Add docs and examples of ex_doc for this case here
      defp query_where(queryable, {k, map_cond}, opts) when not is_list(map_cond) do
        if opts[:binding] == :last do
          from([..., c] in queryable, where: field(c, ^String.to_existing_atom(k)) == ^map_cond)
        else
          from(q in queryable, where: field(q, ^String.to_existing_atom(k)) == ^map_cond)
        end
      end

      # TODO: Add docs and examples of ex_doc for this case here
      defp query_where(queryable, {k, map_cond}, opts) when is_list(map_cond) and k == "$notNull" do
        Enum.reduce(map_cond, queryable, fn key, queryable ->
          if opts[:binding] == :last do
            from([..., c] in queryable, where: not is_nil(field(c, ^String.to_existing_atom(key))))
          else
            from(q in queryable, where: not is_nil(field(q, ^String.to_existing_atom(key))))
          end
        end)
      end
    end
  end
end
