defmodule FatEcto do
  @moduledoc """



  ## Description

  Currently it's supporting following **query functions**:

  - where
  - select
  - joins
  - order_by
  - include
  - group_by

  ### Where

  _Where_ include methods from [Ecto.Query.API](https://hexdocs.pm/ecto/Ecto.Query.API.html). These are the options _where_ supports.

  | function         | Description                                                                                                        |
  | ---------------- | ------------------------------------------------------------------------------------------------------------------ |
  | like             | matches the substring with the attribute in the database. `"$like"` .                                              |
  | notLike          | return result where value in the substring doesn't match. `"$not_like"` .                                          |
  | ilike            | matches the substring passed with the attribute in the database `"$ilike"` .                                       |
  | notILike         | return result where value in the substring doesn't match.`"$not_ilike"`.                                           |
  | lessthan         | fetch result where value is less than the numerical value `"$lt"` (also apply on non_numerical fields).            |
  | lessthanequal    | fetch result where value is less than equal to the numerical value `"$lte"` (also apply on non_numerical fields.   |
  | greaterthan      | fetch result where value is greater than the numerical value `"$gt`" (also apply on non_numerical fields.)         |
  | greaterthanequal | fetch result where value is greater than equal to the numerical value `"gte"` (also apply on non_numerical fields. |
  | between          | [] ,fetch the result wher value is between the provided attributes. `"$between"`.                                  |
  | notBetween       | [] . fetch the result wher value is not between the provided list attributes. `"$not_between"`.                    |
  | in               | [] , fetch result where value is in the the provided list attributes. `"$in"` .                                    |
  | notIn            | [] ,fetch result where value is not in the the provided list attributes. `"$not_in"` .                             |
  | isnil            | value is nil. `"nil"`.                                                                                             |
  | not isnil        | value is not nil. `"$not_null"` .                                                                                  |

  #### Example:

  ```elixir
      query_ opts = %{
        "$where" => %{"designation" => %{"$ilike" => "%surge %"}}
      }

     iex> build(FatEcto.FatDoctor, query_opts)
     iex> #Ecto.Query<from f in FatEcto.FatDoctor,
      where: ilike(fragment("(?)::TEXT", f.designation), ^"%surge %") and ^true>

     query_ opts = %{
        "$where" => %{"rating" => %{"$lte" => "$total_staff"}}
      }

     iex> build(FatEcto.FatHospital, opts)
     iex> #Ecto.Query<from f in FatEcto.FatHospital,
          where: f.rating <= f.total_staff and ^true>
  ```


  ### Select

  _Select_ include fields from the models as well as from the associated models and also adds foreign key dynamically.
  It also select fields from the model as a list.

  #### Example:

  ```elixir
  query_opts = %{
      "$select" => ["name", "location", "rating"],
      "$order" => %{"id" => "$desc"}
  }
  iex> build(FatEcto.FatHospital, query_opts)
  iex> #Ecto.Query<from f in FatEcto.FatHospital, order_by: [desc: f.id],
       select: map(f, [:name, :location, :rating])>

  query_ opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "fat_rooms" => ["beds", "capacity"]
      },
      "$where" => %{"id" => 2}
  }
  iex> build(FatEcto.FatHospital, query_opts)
  iex> #Ecto.Query<from f in FatEcto.FatHospital, where: f.id == ^2 and ^true,
       select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>
  ```


  ### Joins

  _Joins_ with another table on the type of join you passed in the params. it also supports _where_ , _select_, _order_ . Supported Join types are:

  - inner
  - left
  - right
  - full

  #### Example

  ```elixir
  query_opts = %{
        "$right_join" => %{
          "fat_rooms" => %{
            "$on_field" => "id",
            "$on_table_field" => "hospital_id",
            "$select" => ["beds", "capacity", "level"],
            "$where" => %{"incharge" => "John"},
            "$order" => %{"nurses" => "$asc"}
          }
        }
      }
  iex> build(FatEcto.FatHospital, opts)
  iex> Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms",
       on: f0.id == f1.hospital_id, where: f1.incharge == ^"John" and ^true,
       order_by: [asc: f1.nurses],
       select: merge(f0, %{^:fat_rooms => map(f1, [:beds, :capacity, :level])})>
  ```


  ### Order_by

  _order_by_ returns the query by sort the results as _asc_ or _desc_ order.

  #### Example

  ```elixir
  query_opts = %{
        "$select" => %{
          "$fields" => ["name", "location", "rating"],
          "fat_rooms" => ["beds", "capacity"]
        },
        "$order" => %{"id" => "$desc"}
      }
      iex> build(FatEcto.FatHospital, opts)
      iex> #Ecto.Query<from f in FatEcto.FatHospital, order_by: [desc: f.id],
           select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>

  query_ opts = %{
        "$select" => ["name", "location", "rating"],
        "$order" => %{"id" => "$asc"}
      }
  iex> build(FatEcto.FatHospital, query_opts)
  iex> #Ecto.Query<from f in FatEcto.FatHospital, order_by: [asc: f.id],
       select: map(f, [:name, :location, :rating])>
  ```


  ### Include

  _include_ has different sub methods. You can specify the _where_ , _order_by_ , _join_ in the include for the associated schema.

  #### Example

  ```elixir
  query_opts = %{
        "$include" => %{
          "fat_hospitals" => %{
            "$join" => "$right",
            "$order" => %{"id" => "$desc"},
            "$where" => %{"name" => "Saint"}
          }
        },
        "$where" => %{"name" => "John"}
      }
  iex> build(FatEcto.FatDoctor, opts)
  iex> #Ecto.Query<from f0 in FatEcto.FatDoctor,
       right_join: f1 in assoc(f0, :fat_hospitals),
       where: f0.name == ^"John" and ^true,
       preload: [fat_hospitals: #Ecto.Query<from f in FatEcto.FatHospital,
       where: f.name == ^"Saint" and ^true, order_by:  [desc: f.id], limit: ^10, offset: ^0>]>
  ```


  ### Group_By

  _group_by_ Groups together rows from the schema that have the same values in the given fields. It also supports multiple _group_by_ fields in a list.

  #### Example

  ```elixir
  query_opts = %{
        "$inner_join" => %{
          "fat_rooms" => %{
            "$on_field" => "id",
            "$on_table_field" => "hospital_id",
            "$select" => ["beds", "capacity", "level"],
            "$where" => %{"incharge" => "John"}
          }
        },
        "$where" => %{"rating" => 3},
        "$group" => ["rating", "total_staff"]
      }

  iex> build(FatEcto.FatHospital, query_opts)
  iex> #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in "fat_rooms",
       on: f0.id == f1.hospital_id, where: f0.rating == ^3 and ^true,
       where: f1.incharge == ^"John" and ^true, group_by: [f0.rating],
       group_by: [f0.total_staff],
       select: merge(f0, %{^:fat_rooms => map(f1, [:beds, :capacity, :level])})>

  query_opts = %{
        "$select" => ["name", "location", "rating"],
        "$order" => %{"id" => "$asc"},
        "$group" => "rating"
      }

  iex>  build(FatEcto.FatHospital, query_opts)
  iex>  #Ecto.Query<from f in FatEcto.FatHospital, group_by: [f.rating],
        order_by: [asc: f.id], select: map(f, [:name, :location, :rating])>
  ```


  ### Paginator

  _FAT_ allows to restrict the number of results you want to return from the repo. You can define _limit_ as limit and _offset_ as skip.

  #### Example

  ```elixir
  opts = %{
        "$select" => ["name", "location", "rating"],
        "$order" => %{"id" => "$asc"},
        "$group" => "rating",
        "$limit" => 20,
        "$skip" => 0
      }
  ```

  If no limit is defined then FAT automatically uses `default_limit`. For this to work you have to define the default_limit in fat_ecto config.
  see docs for more info.

  """
end
