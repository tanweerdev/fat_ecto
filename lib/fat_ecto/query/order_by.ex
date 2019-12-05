defmodule FatEcto.FatQuery.FatOrderBy do
  # TODO: Add docs and examples for ex_doc
  import Ecto.Query
  alias FatEcto.FatHelper

  @moduledoc """
  Order supports `asc` and `desc` query methods.




  ## => $asc


  ### Parameters

  - `queryable`- Schema name that represents your database model.
  - `query_opts` - include query options as a map.


  ### Example

       iex> query_opts = %{
       ...> "$select" => %{
       ...>   "$fields" => ["name", "location", "rating"],
       ...>   "fat_rooms" => ["floor", "name"]
       ...>  },
       ...>  "$where" => %{"name" => "saint claire"},
       ...>  "$group" => ["rating", "total_staff"],
       ...>  "$order" => %{"total_staff" => "$asc"},
       ...>  "$include" => %{
       ...>    "fat_doctors" => %{
       ...>     "$include" => ["fat_patients"],
       ...>     "$where" => %{"rating" => %{"$gt" => 5}},
       ...>     "$order" => %{"experience_years" => "$asc"},
       ...>     "$select" => ["name", "designation", "phone"]
       ...>    }
       ...>   },
       ...>  "$right_join" => %{
       ...>    "fat_rooms" => %{
       ...>      "$on_field" => "id",
       ...>      "$on_table_field" => "hospital_id",
       ...>      "$select" => ["floor", "name", "is_active"],
       ...>      "$where" => %{"floor" => 10},
       ...>      "$order" => %{"name" => "$asc"}
       ...>     }
       ...>   }
       ...> }
       iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
       #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: f0.name == ^"saint claire" and ^true, where: f1.floor == ^10 and ^true, where: f2.rating > ^5 and ^true, group_by: [f0.rating], group_by: [f0.total_staff], order_by: [asc: f1.name], order_by: [asc: f2.experience_years], order_by: [asc: f0.total_staff], limit: ^34, offset: ^0, select: merge(merge(merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]), %{^"fat_rooms" => map(f1, [:floor, :name, :is_active])}), %{"$group" => %{^"rating" => map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]).rating}}), %{"$group" => %{^"total_staff" => map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]).total_staff}}), preload: [[fat_doctors: [:fat_patients]]]>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$right_join: :$select`- Select the fields from  `rooms`.
  - `$include: :$select`- Select the fields from  `doctors`.
  - `$right_join`- Right join the table `rooms`.
  - `$include`- Include the assoication model `doctors` and `patients`.
  - `$gt`- Added the greaterthan attribute in the  where query inside include .
  - `$order`- Sort the result based on the order attribute.
  - `$right_join: :$order`- Sort the result based on the order attribute inside join.
  - `$include: :$order`- Sort the result based on the order attribute inside include.
  - `$group`- Added the group_by attribute in the query.


  ## => $desc


  ### Parameters

  - `queryable`- Schema name that represents your database model.
  - `query_opts` - include query options as a map.


  ### Example

       iex> query_opts = %{
       ...> "$select" => %{
       ...>   "$fields" => ["name", "location", "rating"],
       ...>   "fat_rooms" => ["floor", "name"]
       ...>  },
       ...>  "$where" => %{"name" => "saint claire"},
       ...>  "$group" => ["rating", "total_staff"],
       ...>  "$order" => %{"rating" => "$desc"},
       ...>  "$include" => %{
       ...>    "fat_doctors" => %{
       ...>     "$include" => ["fat_patients"],
       ...>     "$where" => %{"rating" => %{"$gt" => 5}},
       ...>     "$order" => %{"experience_years" => "$asc"},
       ...>     "$select" => ["name", "designation", "phone"]
       ...>    }
       ...>   },
       ...>  "$right_join" => %{
       ...>    "fat_rooms" => %{
       ...>      "$on_field" => "id",
       ...>      "$on_table_field" => "hospital_id",
       ...>      "$select" => ["name", "floor", "is_active"],
       ...>      "$where" => %{"floor" => 10},
       ...>      "$order" => %{"floor" => "$desc"}
       ...>     }
       ...>   }
       ...> }
       iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
       #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: f0.name == ^"saint claire" and ^true, where: f1.floor == ^10 and ^true, where: f2.rating > ^5 and ^true, group_by: [f0.rating], group_by: [f0.total_staff], order_by: [desc: f1.floor], order_by: [asc: f2.experience_years], order_by: [desc: f0.rating], limit: ^34, offset: ^0, select: merge(merge(merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]), %{^"fat_rooms" => map(f1, [:name, :floor, :is_active])}), %{"$group" => %{^"rating" => map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]).rating}}), %{"$group" => %{^"total_staff" => map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]).total_staff}}), preload: [[fat_doctors: [:fat_patients]]]>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$right_join: :$select`- Select the fields from  `rooms`.
  - `$include: :$select`- Select the fields from  `doctors`.
  - `$right_join`- Right join the table `rooms`.
  - `$include`- Include the assoication model `doctors` and `patients`.
  - `$gt`- Added the greaterthan attribute in the  where query inside include .
  - `$order`- Sort the result based on the order attribute.
  - `$right_join: :$order`- Sort the result based on the order attribute inside join.
  - `$include: :$order`- Sort the result based on the order attribute inside include.
  - `$group`- Added the group_by attribute in the query.

  """

  alias FatEcto.FatHelper
  # TODO: Add docs and examples for ex_doc
  @doc """
  Build a  `order_by query` depending on the params.
  ## Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map
  ## Examples
      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["name", "floor"]
      ...>  },
      ...>  "$order" => %{"id" => "$asc"},
      ...>  "$where" => %{"rating" => 4},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"designation" => "ham"},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>  }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, where: f1.designation == ^"ham" and ^true, order_by: [desc: f1.id], order_by: [asc: f0.id], limit: ^34, offset: ^0, select: map(f0, [:name, :location, :rating, {:fat_rooms, [:name, :floor]}]), preload: [[fat_doctors: [:fat_patients]]]>



  ## Options

    - `$include`- Include the assoication `doctors`.
    - `$select`- Select the fields `from FatEcto.FatHospital` and `rooms`.
    - `$where`- Added the where attribute in the query.
    - `$order`- Sort the result based on the order attribute.
  """
  def build_order_by(queryable, group_params, build_options, opts \\ [])

  def build_order_by(queryable, nil, _build_options, _opts) do
    queryable
  end

  def build_order_by(queryable, order_by_params, build_options, opts) do
    # TODO: Add docs and examples of ex_doc for this case here
    Enum.reduce(order_by_params, queryable, fn {field, format}, queryable ->
      # TODO: Add docs and examples of ex_doc for this case here
      FatHelper.check_params_validity(build_options, queryable, field)

      if opts[:binding] == :last do
        if format == "$desc" do
          from([q, ..., c] in queryable,
            order_by: [desc: field(c, ^FatHelper.string_to_existing_atom(field))]
          )
        else
          # TODO: Add docs and examples of ex_doc for this case here
          from(
            [q, ..., c] in queryable,
            order_by: [
              asc: field(c, ^FatHelper.string_to_existing_atom(field))
            ]
          )
        end
      else
        if format == "$desc" do
          from(queryable,
            order_by: [desc: ^FatHelper.string_to_existing_atom(field)]
          )
        else
          # TODO: Add docs and examples of ex_doc for this case here
          from(
            queryable,
            order_by: [
              asc: ^FatHelper.string_to_existing_atom(field)
            ]
          )
        end
      end
    end)
  end
end
