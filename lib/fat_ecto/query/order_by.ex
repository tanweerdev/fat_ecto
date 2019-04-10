defmodule FatEcto.FatQuery.FatOrderBy do
  # TODO: Add docs and examples for ex_doc
  import Ecto.Query

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
       ...>   "fat_rooms" => ["beds", "capacity"]
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
       ...>      "$on_join_table_field" => "hospital_id",
       ...>      "$select" => ["beds", "capacity", "level"],
       ...>      "$where" => %{"beds" => 10},
       ...>      "$order" => %{"nurses" => "$asc"}
       ...>     }
       ...>   }
       ...> }
       iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
       #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: f0.name == ^"saint claire" and ^true, where: f1.beds == ^10 and ^true, group_by: [f0.rating], group_by: [f0.total_staff], order_by: [asc: f1.nurses], order_by: [asc: f0.total_staff], select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating > ^5 and ^true, order_by: [asc: f.experience_years], limit: ^103, offset: ^0, select: map(f, [:name, :designation, :phone]), preload: [:fat_patients]>]>


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
       ...>   "fat_rooms" => ["beds", "capacity"]
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
       ...>      "$on_join_table_field" => "hospital_id",
       ...>      "$select" => ["beds", "capacity", "level"],
       ...>      "$where" => %{"beds" => 10},
       ...>      "$order" => %{"capacity" => "$desc"}
       ...>     }
       ...>   }
       ...> }
       iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
       #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: f0.name == ^"saint claire" and ^true, where: f1.beds == ^10 and ^true, group_by: [f0.rating], group_by: [f0.total_staff], order_by: [desc: f1.capacity], order_by: [desc: f0.rating], select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating > ^5 and ^true, order_by: [asc: f.experience_years], limit: ^103, offset: ^0, select: map(f, [:name, :designation, :phone]), preload: [:fat_patients]>]>


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
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$asc"},
      ...>  "$where" => %{"rating" => 4},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"name" => "ham"},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>  }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, order_by: [asc: f0.id], select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.name == ^"ham" and ^true, order_by: [desc: f.id], limit: ^103, offset: ^0, preload: [:fat_patients]>]>




  ## Options

    - `$include`- Include the assoication `doctors`.
    - `$select`- Select the fields `from FatEcto.FatHospital` and `rooms`.
    - `$where`- Added the where attribute in the query.
    - `$order`- Sort the result based on the order attribute.
  """

  def build_order_by(queryable, nil) do
    queryable
  end

  def build_order_by(queryable, order_by_params) do
    # TODO: Add docs and examples of ex_doc for this case here
    Enum.reduce(order_by_params, queryable, fn {field, format}, queryable ->
      # TODO: Add docs and examples of ex_doc for this case here
      if format == "$desc" do
        from(
          queryable,
          order_by: [
            desc: ^FatHelper.string_to_existing_atom(field)
          ]
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
    end)
  end
end
