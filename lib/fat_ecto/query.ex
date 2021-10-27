defmodule FatEcto.FatQuery do
  # TODO: make paginator optional via global config and via options passed
  defmacro __using__(options \\ []) do
    quote location: :keep do
      # TODO: add typespecs. good example is https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/repo.ex
      # TODO: repo typespec is Ecto.Repo.t eg is https://github.com/elixir-ecto/ecto/blob/7f9a1420b6dfcf4b2df8b715db287d2cfd5361fb/lib/mix/ecto.ex
      @moduledoc """
      Entry Point module for building queries.

      `import` or `alias` it inside your module.
      """

      @opt_app unquote(options)[:otp_app]
      @options FatEcto.FatHelper.get_module_options(unquote(options)[:otp_app], :fat_query, unquote(options), [])

      @repo @options[:repo][:module]
      if !@repo do
        raise "please define repo when using fat query methods"
      end

      @query_param_defaults %{
        "$find" => "$all",
        "$where" => nil,
        # TODO: $max and $min should be part of select as in example docs
        "$max" => nil,
        "$min" => nil,
        "$include" => nil,
        "$select" => nil,
        "$order" => nil,
        # TODO: $group should be part of select
        "$group" => nil,
        "$skip" => 0,
        "$limit" => @options[:default_limit] || 10,
        "$count_on" => nil
      }

      use FatEcto.FatPaginator, @options

      # import FatEcto.FatQuery.FatWhere, only: [build_where: 2] # import and use like this if without defmacro
      # import FatEcto.FatQuery.FatOrderBy, only: [build_order_by: 2]
      # import FatEcto.FatQuery.FatInclude, only: [build_include: 3]
      # import FatEcto.FatQuery.FatSelect, only: [build_select: 4]
      # import FatEcto.FatQuery.FatJoin, only: [build_join: 2]
      # import FatEcto.FatQuery.FatGroupBy, only: [build_group_by: 2]

      import Ecto.Query
      alias FatEcto.FatQuery.FatWhere
      alias FatEcto.FatQuery.FatOrderBy
      alias FatEcto.FatQuery.FatInclude
      alias FatEcto.FatQuery.FatSelect
      alias FatEcto.FatQuery.FatJoin
      alias FatEcto.FatQuery.FatGroupBy
      alias FatEcto.FatQuery.FatAggregate

      defdelegate build_where(queryable, params, build_options), to: FatWhere
      defdelegate build_order_by(queryable, params, build_options), to: FatOrderBy
      defdelegate build_include(queryable, params, model, build_options), to: FatInclude
      defdelegate build_select(queryable, params, model, build_options), to: FatSelect
      defdelegate build_join(queryable, params, build_options), to: FatJoin
      defdelegate build_group_by(queryable, params, build_options), to: FatGroupBy
      defdelegate build_aggregate(queryable, params, build_options), to: FatAggregate

      # TODO: Should return {:ok, query}
      @doc """
      Call the `respective query method` depending on the params.
      ## Parameters

        - `queryable`- Schema name that represents your database model.
        - `query_opts` - include query options as a map
      ## Examples
          iex> query_opts = %{
          ...>   "$select" => %{
          ...>     "$fields" => ["name", "location", "rating"],
          ...>     "fat_rooms" => ["floor", "name"]
          ...>  },
          ...>   "$order" => %{"id" => "$desc"},
          ...>   "$where" => %{"rating" => 4},
          ...>   "$group" => "rating",
          ...>   "$include" => %{
          ...>       "fat_doctors" => %{
          ...>           "$include" => ["fat_patients"],
          ...>           "$where" => %{"designation" => "ham"},
          ...>           "$order" => %{"id" => "$desc"},
          ...>           "$join" => "$right"
          ...>          }
          ...>     },
          ...>   "$right_join" => %{
          ...>      "fat_rooms" => %{
          ...>        "$on_field" => "id",
          ...>        "$on_table_field" => "hospital_id",
          ...>        "$select" => ["name", "floor", "is_active"],
          ...>        "$where" => %{"name" => "John"}
          ...>       }
          ...>     }
          ...>  }
          iex> build!(FatEcto.FatHospital, query_opts, paginate: false)
          #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in \"fat_rooms\", on: f0.id == f1.hospital_id, right_join: f2 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, where: f1.name == ^\"John\" and ^true, where: f2.designation == ^\"ham\" and ^true, group_by: [f0.rating], order_by: [desc: f2.id], order_by: [desc: f0.id], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]), %{^\"fat_rooms\" => map(f1, [:name, :floor, :is_active])}), preload: [[fat_doctors: [:fat_patients]]]>


      ## Examples
        iex> query_opts = %{
        ...>   "$select" => %{
        ...>     "$fields" => ["name", "rating"],
        ...>     "fat_beds" => ["name", "description"]
        ...>  },
        ...>   "$order" => %{"id" => "$desc"},
        ...>   "$where" => %{"rating" => 2},
        ...>   "$group" => "rating",
        ...>   "$include" => %{
        ...>       "fat_doctors" => %{
        ...>           "$include" => ["fat_patients"],
        ...>           "$where" => %{"designation" => "ham"},
        ...>           "$order" => %{"id" => "$desc"},
        ...>           "$join" => "$right"
        ...>          }
        ...>     },
        ...>   "$right_join" => %{
        ...>      "fat_beds" => %{
        ...>        "$on_field" => "id",
        ...>        "$on_table_field" => "hospital_id",
        ...>        "$select" => ["name", "description"],
        ...>        "$where" => %{"name" => "John"}
        ...>       }
        ...>     }
        ...>  }
        iex> build!(FatEcto.FatHospital, query_opts, paginate: false)
        #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in \"fat_beds\", on: f0.id == f1.hospital_id, right_join: f2 in assoc(f0, :fat_doctors), where: f0.rating == ^2 and ^true, where: f1.name == ^\"John\" and ^true, where: f2.designation == ^\"ham\" and ^true, group_by: [f0.rating], order_by: [desc: f2.id], order_by: [desc: f0.id], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :rating, {:fat_beds, [:name, :description]}]), %{^\"fat_beds\" => map(f1, [:name, :description])}), preload: [[fat_doctors: [:fat_patients]]]>



      ## Options

        - `$include`- Include the assoication model `doctors`.
        - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
        - `$select`- Select the fields from `hospital` and `rooms`.
        - `$where`- Added the where attribute in the query.
        - `$group`- Added the group_by attribute in the query.
        - `$order`- Sort the result based on the order attribute.
        - `$right_join`- Specify the type of join.
        - `$on_field`- Specify the field for join.
        - `$on_table_field`- Specify the field for join in the joining table.
      """

      def build!(queryable, query_opts, build_options \\ []) do
        build_options = Keyword.merge(@options, build_options)
        query_opts = FatUtils.Map.deep_merge(@query_param_defaults, query_opts)

        model =
          if is_atom(queryable) || is_binary(queryable) do
            queryable
          else
            %{source: {_table, model}} = queryable.from
            model
          end

        build_query(queryable, query_opts, model, build_options)
      end

      defp build_query(queryable, opts, model, build_options) do
        # TODO: LIMP: first confirm the field exist in the schema
        # from(q in queryable, as: :base_table)
        queryable
        |> FatEcto.FatQuery.FatSelect.build_select(opts["$select"], model, build_options)
        |> FatEcto.FatQuery.FatWhere.build_where(opts["$where"], build_options)
        |> FatEcto.FatQuery.FatJoin.build_join(opts["$join"], "$join", build_options)
        |> FatEcto.FatQuery.FatJoin.build_join(opts["$right_join"], "$right_join", build_options)
        |> FatEcto.FatQuery.FatJoin.build_join(opts["$left_join"], "$left_join", build_options)
        |> FatEcto.FatQuery.FatJoin.build_join(opts["$inner_join"], "$inner_join", build_options)
        |> FatEcto.FatQuery.FatJoin.build_join(opts["$full_join"], "$full_join", build_options)
        |> FatEcto.FatQuery.FatInclude.build_include(opts["$include"], model, build_options)
        |> FatEcto.FatQuery.FatInclude.build_include_preloads(opts["$include"])
        |> FatEcto.FatHelper.remove_conflicting_order_by(opts["$distinct_nested"])
        |> FatEcto.FatQuery.FatDistinct.build_distinct(opts["$distinct"], build_options)
        |> FatEcto.FatQuery.FatOrderBy.build_order_by(opts["$order"], build_options)
        |> FatEcto.FatQuery.FatAggregate.build_aggregate(opts["$aggregate"], build_options)
        |> FatEcto.FatQuery.FatGroupBy.build_group_by(opts["$group"], build_options)
      end

      @doc """
         Fetch the result from the repo based on the query params.

      ## Parameters

        - `queryable`- Schema name that represents your database model.
        - `query_opts` - include query options as a map

      ## Examples
          iex> query_opts = %{
          ...>  "$find" => "$all",
          ...>  "$select" => %{"$fields" => ["name", "rating"], "fat_rooms" => ["name"]},
          ...>  "$where" => %{"id" => 10}
          ...> }
          iex> build!(FatEcto.FatHospital, query_opts, paginate: false)
          #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.id == ^10 and ^true, select: map(f0, [:name, :rating, {:fat_rooms, [:name]}])>



      ## Options

        - `$find => $all`- To fetch all the results from database.
        - `$find => $one`- To fetch single record from database.
        - `$select`- Select the fields from `hospital` and `rooms`.
        - `$where`- Added the where attribute in the query.

      """

      # You can get two types of error from this fetch method.
      # fat_ecto_query_error and fat_ecto_query_db_error

      def build_by(queryable, query_params, options \\ []) do
        query_param_defaults = options[:defaults] || @query_param_defaults
        query_params = FatUtils.Map.deep_merge(query_param_defaults, query_params)

        queryable =
          try do
            build!(queryable, query_params, options)
          rescue
            e in ArgumentError -> {:error, e}
          end
        case queryable do
          {:error, info} ->
            %{message: error_message} = info
            {:fat_ecto_query_error, error_message}

          _ ->
            options =
              [paginate: true, timeout: 15000]
              |> Keyword.merge(@options)
              |> Keyword.merge(options)

            case query_params["$find"] do
              "$one" ->
                {:ok, %{query: queryable, type: :object}}

              "$all" ->
                if options[:paginate] == true do
                  %{
                    data_query: data_query,
                    skip: skip,
                    limit: limit,
                    count_query: count_query
                  } = paginate(queryable, skip: query_params["$skip"], limit: query_params["$limit"])

                  {:ok,
                   %{
                     query: data_query,
                     type: :array,
                     meta: %{skip: skip, limit: limit, count_query: count_query}
                   }}
                else
                  {:ok, %{query: queryable, type: :array, meta: nil}}
                end

              nil ->
                {:fat_ecto_query_error, :find_method_not_found}

              _ ->
                {:fat_ecto_query_error, :find_method_not_found}
            end
        end
      end

      def fetch(queryable, query_params, fetch_options \\ []) do
        with {:ok, query_data} <- build_by(queryable, query_params, fetch_options) do
          case query_data do
            %{query: queryable, type: :object} ->
              {:ok,
               %{
                 data: @repo.one(Ecto.Query.limit(queryable, 1)),
                 type: :object,
                 meta: nil
               }}

            #  when pagination is set to false
            %{query: queryable, type: :array, meta: nil} ->
              try do
                {:ok,
                 %{
                   data: @repo.all(queryable, fetch_options[:repo] || []),
                   type: :array,
                   meta: nil
                 }}
              rescue
                DBConnection.ConnectionError ->
                  {:fat_ecto_query_db_error, :timeout}

                other_error ->
                  {:fat_ecto_query_db_error, other_error}
              end

            %{query: data_query, type: :array, meta: %{skip: skip, limit: limit, count_query: count_query}} ->
              try do
                {:ok,
                 %{
                   data: @repo.all(data_query, fetch_options[:repo] || []),
                   type: :array,
                   meta: %{
                     skip: skip,
                     limit: limit,
                     count: count_records(count_query, fetch_options[:repo], query_params["$count_on"] || nil )
                   }
                 }}
              rescue
                DBConnection.ConnectionError ->
                  {:fat_ecto_query_db_error, :timeout}

                other_error ->
                  {:fat_ecto_query_db_error, other_error}
              end
          end
        end
      end

      def count_records(%{select: nil} = records, fetch_opts, count_on) do
        if !is_nil(count_on) && is_binary(count_on) do
          @repo.aggregate(
            records,
            :count,
            String.to_atom(count_on),
            fetch_opts
          )
        else
          @repo.aggregate(
            records,
            :count,
            FatEcto.FatHelper.get_primary_keys(records) |> hd(),
            fetch_opts
          )
        end
      end

      def count_records(records, fetch_opts, _count_on) do
        @repo.one(records, fetch_opts)
      end
    end
  end
end
