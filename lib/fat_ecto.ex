defmodule FatEcto do
  @moduledoc """



  ## Description

  Currently it's supporting following **query functions**:

  - where
  - where_or
  - select
  - joins
  - order_by
  - include
  - group_by
  - aggregate
  - distinct

  ### Where

  _Where_ include methods from [Ecto.Query.API](https://hexdocs.pm/ecto/Ecto.Query.API.html). These are the options _where_ supports.

  | function         | Description                                                                                                        |
  | ---------------- | ------------------------------------------------------------------------------------------------------------------ |
  | like             | matches the substring with the attribute in the database. `"$like"` .                                              |
  | notlike          | return result where value in the substring doesn't match. `"$not_like"` .                                          |
  | ilike            | matches the substring passed with the attribute in the database `"$ilike"` .                                       |
  | notiLike         | return result where value in the substring doesn't match.`"$not_ilike"`.                                           |
  | lessthan         | fetch result where value is less than the numerical value `"$lt"` (also apply on non_numerical fields).            |
  | lessthanequal    | fetch result where value is less than equal to the numerical value `"$lte"` (also apply on non_numerical fields.   |
  | greaterthan      | fetch result where value is greater than the numerical value `"$gt`" (also apply on non_numerical fields.)         |
  | greaterthanequal | fetch result where value is greater than equal to the numerical value `"gte"` (also apply on non_numerical fields. |
  | between          | [] ,fetch the result where value is between the provided attributes. `"$between"`.                                  |
  | betweenequal     | [] ,fetch the result where value is equal and between the provided attributes. `"$between_equal"`.                                  |
  | notbetween       | [] ,fetch the result where value is not between the provided list attributes. `"$not_between"`.                    |
  | notbetweenequal  | [] ,fetch the result where value is not equal and between the provided list attributes. `"$not_between_equal"`.                    |
  | in               | [] ,fetch result where value is in the the provided list attributes. `"$in"` .                                    |
  | notin            | [] ,fetch result where value is not in the the provided list attributes. `"$not_in"` .                             |
  | contains         | [] ,fetch the key from the josnb field and see if it contains the value. `"$contains"` .                             |
  | containany       | [] ,fetch the key from the josnb field and see if it contains any of the values passed. `"$contains_any"` .                             |
  | isnil            | value is nil. `"nil"`.                                                                                             |
  | notisnil        | value is not nil. `"$not_null"` .                                                                                  |

  #### Example:

  ```elixir
      query_ opts = %{
       "$where" => %{
          "name" => "%Joh%",
          "location" => nil,
          "$not_null" => ["total_staff", "address", "phone"],
          "rating" => "$not_null",
          "total_staff" => %{"$between" => [1, 3]}
        }
      }

     iex> build(FatEcto.FatHospital, query_opts)
     iex> #Ecto.Query< from(f0 in FatEcto.FatHospital,
          where:
          f0.total_staff > ^1 and f0.total_staff < ^3 and
            (not is_nil(f0.rating) and
               (f0.name == ^"%Joh%" and
                  (is_nil(f0.location) and
                     (not is_nil(f0.phone) and
                        (not is_nil(f0.address) and (not is_nil(f0.total_staff) and ^true))))))
           )>

     query_ opts = %{
        "$where" => %{"rating" => %{"$lte" => "$total_staff"}}
      }

     iex> build(FatEcto.FatHospital, opts)
     iex> #Ecto.Query<from f in FatEcto.FatHospital,
          where: f.rating <= f.total_staff and ^true>
  ```

  ### Where_or
  Add _or_ clause in the _where_ when building a query._where_or_ is useful when you want to add multiple _or_ conditions in the where conditional.

  ### Example:

  ```elixir
  query_opts = %{
      "$where" => %{
        "$or" => %{
          "name" => %{"$like" => "%Joh%"},
          "total_staff" => %{"$between_equal" => [5, 7]}
        }
      }
    }
  iex> build(FatEcto.FatHospital, query_opts)
  iex> #Ecto.Query<from(f0 in FatEcto.FatHospital,
        where:
          (f0.total_staff >= ^5 and f0.total_staff <= ^7) or
            (like(fragment("(?)::TEXT", f0.name), ^"%Joh%") or ^true))>
  ```

  ### Select

  _Select_ fields from the schema as well as from the associated schemas. You can pass fields as a list or in a map.


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

  _Joins_ with another table on the type of join you passed in the params. It supports _where_ , _select_, _order_by_, _group_by_ . Additionally, it also supports _additional_on_clauses_. Supported Join types are:

  - inner
  - left
  - right
  - full

  #### Example

  ```elixir
  query_opts = %{
      "$select" => %{"$fields" => ["designation", "experience_years"]},
      "$full_join" => %{
        "fat_patients" => %{
          "$on_field" => "id",
          "$on_table_field" => "doctor_id",
          "$where" => %{"location" => "bullavard"},
          "$select" => ["name", "prescription"],
          "$order" => %{"appointments_count" => "$asc"},
          "$group" => "experience_years"
        }
      }
    }
  iex> build(FatEcto.FatDoctor, query_opts)
  iex> #Ecto.Query<from f0 in FatEcto.FatDoctor, full_join: f1 in "fat_patients",
       on: f0.id == f1.doctor_id, where: f1.location == ^"bullavard" and ^true,
       group_by: [f1.experience_years], order_by: [asc: f1.appointments_count],
       select: merge(merge(map(f0, [:designation, :experience_years]), %{^"fat_patients" => map(f1, [:name, :prescription])}), %{"$group" => %{^"experience_years" => map(f1, [:name, :prescription]).experience_years}})>

  query_opts = %{
      "$inner_join" => %{
        "fat_rooms" => %{
          "$on_field" => "id",
          "$on_table_field" => "hospital_id",
          "$additional_on_clauses" => %{
            "rating" => %{"$not_between" => [1, 3]},
            "total_staff" => %{"$not_between_equal" => [4, 5]}
          },
          "$select" => ["beds", "capacity", "level"],
          "$where" => %{"incharge" => "John"}
        }
      },
      "$where" => %{"rating" => 3}
    }   
  iex> build(FatEcto.FatHospital, query_opts)
  iex> #Ecto.Query<from(
         h in FatEcto.FatHospital,
         where: h.rating == ^3 and ^true,
         inner_join: r in "fat_rooms",
         on:
          h.id == r.hospital_id and
            ((h.total_staff <= ^4 or h.total_staff >= ^5) and ((h.rating < ^1 or h.rating > ^3) and ^true)),
         where: r.incharge == ^"John" and ^true,
         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
        )>  
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

  _include_ preload tables based on the conditions passed in the query params. You can specify the _where_ , _order_by_ , _join_, _group_by_ in the include for the associated tables. You can also use nested _include_ to preload nested relationships.

  #### Example

  ```elixir
  query_opts = %{
      "$include" => %{
        "fat_hospitals" => %{"$include" => %{"fat_rooms" => %{"$include" => ["fat_hospital", "fat_beds"]}}},
        "fat_patients" => %{
          "$include" => %{
            "fat_doctors" => %{
              "$include" => %{"fat_hospitals" => %{"$include" => "fat_rooms", "$where" => %{"name" => "Joh"}}}
            }
          }
        }
      }
    }
  iex> build(FatEcto.FatDoctor, query_opts)
  iex> #Ecto.Query<from(f0 in FatEcto.FatDoctor,
        left_join: f1 in assoc(f0, :fat_hospitals),
        left_join: f2 in assoc(f1, :fat_rooms),
        left_join: f3 in assoc(f0, :fat_patients),
        left_join: f4 in assoc(f3, :fat_doctors),
        left_join: f5 in assoc(f4, :fat_hospitals),
        where: f5.name == ^"Joh" and ^true,
        limit: ^34,
        offset: ^0,
        preload: [
          ^[
            fat_patients: [fat_doctors: [fat_hospitals: :fat_rooms]],
            fat_hospitals: [fat_rooms: [:fat_hospital, :fat_beds]]
          ]
        ]
      )>
  ```


  ### Group_By

  _group_by_ groups together rows from the schema that have the same values in the given fields. It also supports multiple _group_by_ fields in a list.

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

  ### Aggregate

  _Aggregate_ supports aggregate methods that can be passed as a string or a list.

  | function         | Description                                                                                                        |
  | ---------------- | ------------------------------------------------------------------------------------------------------------------ |
  | max              | Select the maximum value from the records matching the query. `"$max"`.                                            |
  | min              | Select the minimum value from the records matching the query. `"$min"`.                                            |
  | avg              | Calculates the average from the records matching the query. `"$avg"`.                                              |
  | count            | Counts the given entry based on the query passed. `"$count"`                                                       |
  | count_distinct   | Counts the distinct values in given entry based on the query passed.`"$count_distinct"`.                           |
  | sum              | Calculates the sum for the given entry based on the query passed. `$sum`.                                          |

  #### Example

  ```elixir
  query_opts = %{
      "$aggregate" => %{"$max" => "nurses", "$min" => "capacity"},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }
  iex>  build(FatEcto.FatRoom, query_opts)
  iex>  #Ecto.Query<from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(
            merge(merge(f0, %{"$aggregate" => %{"$max": %{^"nurses" => max(f0.nurses)}}}), %{
              "$aggregate" => %{"$min": %{^"capacity" => min(f0.capacity)}}
            }),
            %{"$group" => %{^"capacity" => f0.capacity}})
          )>

  query_opts = %{
      "$aggregate" => %{"$sum" => ["nurses", "beds"], "$avg" => ["capacity", "nurses"]},
      "$where" => %{"capacity" => 5},
      "$group" => "capacity"
    }
  iex>  build(FatEcto.FatRoom, query_opts)
  iex>  #Ecto.Query<from(from(f0 in FatEcto.FatRoom,
        where: f0.capacity == ^5 and ^true,
        group_by: [f0.capacity],
        select:
          merge(
            merge(
              merge(
                merge(merge(f0, %{"$aggregate" => %{"$avg": %{^"capacity" => avg(f0.capacity)}}}), %{
                  "$aggregate" => %{"$avg": %{^"nurses" => avg(f0.nurses)}}
                }),
                %{"$aggregate" => %{"$sum": %{^"nurses" => sum(f0.nurses)}}}
              ),
              %{"$aggregate" => %{"$sum": %{^"beds" => sum(f0.beds)}}}
            ),
            %{"$group" => %{^"capacity" => f0.capacity}}
          )
      ))>
    
  ```
  ### Distinct
    Adds _distinct_ query expression to avoid duplication of records. You can pass the distinct _field name_ or _true_.
  #### Example

  ```elixir
  query_opts = %{
      "$distinct" => "name"
    }

  iex> build(FatEcto.FatHospital, opts)
  iex> Ecto.Query<from(h in FatEcto.FatHospital, distinct: [asc: h.name])>  

  query_opts = %{
      "$distinct" => true
    }

  iex> build(FatEcto.FatHospital, opts)
  iex> Ecto.Query<from(h in FatEcto.FatHospital, distinct: true)>
  ```
  You have to pass ```"$distinct_nested => true"``` alongwith ```"$distinct => true"```  if there are multiple _order_by_ clauses in your query.

  ### Paginator

  _FAT_ allows to restrict the number of results you want to return from the repo. You can define _limit_ as limit and _offset_ as skip in the config.

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

  ### Blacklist params
     Fat ecto provides you control to restrict access to specific fields of different tables in your database. You have to set these fields in your fat ecto config. If these fields are present in the query, fat ecto will raise an error.

  #### Example

  ```elixir
  blacklist_params: [
      {:fat_rooms, ["description"]},
      {:fat_beds, ["is_active"]},
      {:fat_hospitals, ["phone"]},
      {:fat_doctors, ["name"]},
      {:fat_patients, ["date_of_birth"]}
    ]
  query_opts = %{
      "$select" => %{
        "$fields" => ["name", "purpose", "description"],
        "fat_beds" => ["purpose", "description"]
      },
      "$where" => %{"id" => room.id}
    }
  iex> Query.build(FatEcto.FatRoom, query_opts)
  iex>  ** (ArgumentError) the fields ["description"] of fat_rooms are not allowed in the query
  ```
                               
  """
end
