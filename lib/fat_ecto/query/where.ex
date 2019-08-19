defmodule FatEcto.FatQuery.FatWhere do
  # TODO: Add docs and examples for ex_doc
  import Ecto.Query

  @moduledoc """
  Where supports multiple query methods.




  ## => like

  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>   "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
      ...>   "$where" => %{"name" => %{"$like" => "%Joh %"}}
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f in FatEcto.FatDoctor, where: like(fragment("(?)::TEXT", f.name), ^"%Joh %") and ^true, select: map(f, [:name, :designation, :experience_years])>


  ### Options
    - `$select`- Select the fields from `doctor`.
    - `$like`- Added the like attribute in the where query.



  ## => iLike


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>   "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
      ...>   "$where" => %{"designation" => %{"$ilike" => "%surge %"}},
      ...>   "$order" => %{"rating" => "$asc"}
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f in FatEcto.FatDoctor, where: ilike(fragment("(?)::TEXT", f.designation), ^"%surge %") and ^true, order_by: [asc: f.rating], select: map(f, [:name, :designation, :experience_years])>



  ### Options
    - `$select`- Select the fields from `doctor`.
    - `$ilike`- Added the ilike attribute in the where query.
    - `$order`- Sort the result based on the order attribute.



  ## => notLike


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"],
      ...>   },
      ...>  "$where" => %{"location" => %{"$not_like" => "%street2 %"}},
      ...>  "$order" => %{"id" => "$desc"}
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: not(like(fragment("(?)::TEXT", f.location), ^"%street2 %")) and ^true, order_by: [desc: f.id], select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>


  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$not_like`- Added the notlike attribute in the where query.
    - `$order`- Sort the result based on the order attribute.



  ## => notILike


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"]
      ...>   },
      ...>  "$where" => %{"location" => %{"$not_ilike" => "%street2 %"}},
      ...>  "$group" => "rating"
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: not(ilike(fragment("(?)::TEXT", f.location), ^"%street2 %")) and ^true, group_by: [f.rating], select: map(f, [:name, :location, :rating])>


  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$not_ilike`- Added the notilike attribute in the where query.
    - `$group`- Added the group_by attribute in the query.




  ## => lessThan


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map


  ### Example

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "location", "rating"]
      ...>    },
      ...>   "$where" => %{"rating" => %{"$lt" => 4}}
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: f.rating < ^4 and ^true, select: map(f, [:name, :location, :rating])>



  ### Options
    - `$select`- Select the fields from `hospital`.
    - `$lt`- Added the lessthan attribute in the where query.




  ## => lessThan the other field


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>   "$select" => %{
      ...>      "$fields" => ["name", "location", "rating"]
      ...>    },
      ...>    "$where" => %{"total_staff" => %{"$lt" => "$rating"}},
      ...>    "$order" => %{"id" => "$desc"}
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: f.total_staff < f.rating and ^true, order_by: [desc: f.id], select: map(f, [:name, :location, :rating])>


  ### Options
    - `$select`- Select the fields from `hospital`.
    - `$lt: :$field`- Added the lessthan attribute in the where query.
    - `$order`- Sort the result based on the order attribute.




  ## => lessThanEqual


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>   "$select" => %{
      ...>     "$fields" => ["name", "location", "rating"],
      ...>     "fat_rooms" => ["beds", "capacity"]
      ...>    },
      ...>   "$where" => %{"total_staff" => %{"$lte" => 3}},
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: f.total_staff <= ^3 and ^true, select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>


  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$lte`- Added the lessthanequal attribute in the where query.



  ## => lessThanEqual the other field


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>   },
      ...>  "$where" => %{"total_staff" => %{"$lte" => "$rating"}},
      ...>  "$group" => "total_staff"
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: f.total_staff <= f.rating and ^true, group_by: [f.total_staff], select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>

  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$lte: :$field`- Added the lessthanequal attribute in the where query.
    - `$group`- Added the group_by attribute in the query.



  ## => greaterThan


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>   "$fields" => ["name", "location", "rating"],
      ...>   "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$where" => %{"total_staff" => %{"$gt" => 4}},
      ...>  "$group" => "total_staff",
      ...>  "$order" => %{"rating" => "$desc"}
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: f.total_staff > ^4 and ^true, group_by: [f.total_staff], order_by: [desc: f.rating], select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>


  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$gt`- Added the lessthan attribute in the where query.
    - `$group`- Added the group_by attribute in the query.
    - `$order`- Sort the result based on the order attribute.




  ## => greaterThan the other field


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>   "$fields" => ["name", "location", "rating"],
      ...>   "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$where" => %{"total_staff" => %{"$gt" => "$rating"}},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$where" => %{"rating" => %{"$lt" => 3}},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>   }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: f0.total_staff > f0.rating and ^true, select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating < ^3 and ^true, order_by: [desc: f.id], limit: ^103, offset: ^0>]>

  ### Options
    - `$select`- Select the fields from `hospital`.
    - `$gt: :$field`- Added the greaterthan attribute in the where query.
    - `$include`- Include the assoication model `doctors`.
    - `$lt`- Added the lessthan attribute in the where query inside include.



  ## => greaterThanEqual


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>   "$fields" => ["name", "location", "rating"],
      ...>   "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$where" => %{"total_staff" => %{"$gte" => 5}},
      ...>  "$include" => %{
      ...>   "fat_doctors" => %{
      ...>    "$where" => %{"rating" => %{"$lte" => 3}},
      ...>   }
      ...>  }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: f0.total_staff >= ^5 and ^true, select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating <= ^3 and ^true, limit: ^103, offset: ^0>]>

  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$gte`- Added the greaterthanequal attribute in the where query.
    - `$include`- Include the assoication model `doctors`.
    - `$lte`- Added the lessthanequal attribute in the where query inside include.





  ## => greaterThanEqual the other field


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>   },
      ...>  "$where" => %{"rating" => %{"$gte" => "$total_staff"}},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$where" => %{"rating" => %{"$gte" => 3}},
      ...>      "$order" => %{"rating" => "$asc"}
      ...>     }
      ...>   }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: f0.rating >= f0.total_staff and ^true, select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating >= ^3 and ^true, order_by: [asc: f.rating], limit: ^103, offset: ^0>]>


  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$gte: :$field`- Added the  greaterthanequal attribute in the where query.
    - `$include`- Include the assoication model `doctors`.
    - `$gte`- Added the greaterthanequal attribute in the where query inside include.
    - `$order`- Sort the result based on the order attribute.


  ## => between


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>   "$fields" => ["name", "location", "rating"],
      ...>   "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$where" => %{"rating" => %{"$between" => [10, 20]}},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"rating" => %{"$gte" => "$total_staff"}},
      ...>      "$order" => %{"rating" => "$asc"}
      ...>    }
      ...>   }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: f0.rating > ^10 and f0.rating < ^20 and ^true, select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating >= f.total_staff and ^true, order_by: [asc: f.rating], limit: ^103, offset: ^0, preload: [:fat_patients]>]>

  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$between: :$field`- Added the  between attribute in the where query.
    - `$include`- Include the assoication model `doctors` and `patients`.
    - `$gte`- Added the greaterthanequal attribute in the where query inside include.
    - `$order`- Sort the result based on the order attribute.

  ## => not_between


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...> "$select" => %{
      ...>   "$fields" => ["name", "location", "rating"],
      ...>   "fat_rooms" => ["beds", "capacity"]
      ...>   },
      ...>  "$where" => %{"rating" => %{"$not_between" => [10, 20]}},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"rating" => %{"$between" => [20, 30]}},
      ...>      "$order" => %{"experience_years" => "$asc"}
      ...>    }
      ...>   }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: (f0.rating < ^10 or f0.rating > ^20) and ^true, select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating > ^20 and f.rating < ^30 and ^true, order_by: [asc: f.experience_years], limit: ^103, offset: ^0, preload: [:fat_patients]>]>



  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$not_between: :$field`- Added the  notbetween attribute in the where query.
    - `$include`- Include the assoication model `doctors` and `patients`.
    - `$between`- Added the between attribute in the where query inside include.
    - `$order`- Sort the result based on the order attribute.



  ## => in


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>   "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>   },
      ...>   "$where" => %{"rating" => %{"$in" => [10, 20]}},
      ...>   "$include" => %{
      ...>     "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"rating" => %{"$not_between" => [20, 30]}},
      ...>      "$order" => %{"experience_years" => "$asc"}
      ...>     }
      ...>    },
      ...>    "$right_join" => %{
      ...>     "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"beds" => %{"$gte" => "$nurses"}}
      ...>    }
      ...>   }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: f0.rating in ^[10, 20] and ^true, where: f1.beds >= f1.nurses and ^true, select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: (f.rating < ^20 or f.rating > ^30) and ^true, order_by: [asc: f.experience_years], limit: ^103, offset: ^0, preload: [:fat_patients]>]>


  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$right_join: :$select`- Select the fields from  `rooms`.
    - `$right_join`- Right join the table `rooms`.
    - `$gte: :$field`- Added the  greaterthanequal attribute in the where query inside join.
    - `$include`- Include the assoication model `doctors` and `patients`.
    - `$not_between`- Added the notbetween in the  where query inside include .
    - `$in`- Added the in attribute in the where query.
    - `$order`- Sort the result based on the order attribute.


  ## => not_in


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>   "$fields" => ["name", "location", "rating"],
      ...>   "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$where" => %{"rating" => %{"$not_in" => [10, 20]}},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>     "$include" => ["fat_patients"],
      ...>     "$where" => %{"rating" => %{"$not_between" => [20, 30]}},
      ...>     "$order" => %{"rating" => "$desc"}
      ...>    }
      ...>   },
      ...>  "$right_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"beds" => %{"$not_in" => [5, 15]}}
      ...>     }
      ...>   }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: f0.rating not in ^[10, 20] and ^true, where: f1.beds not in ^[5, 15] and ^true, select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: (f.rating < ^20 or f.rating > ^30) and ^true, order_by: [desc: f.rating], limit: ^103, offset: ^0, preload: [:fat_patients]>]>


  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$right_join: :$select`- Select the fields from  `rooms`.
    - `$right_join`- Right join the table `rooms`.
    - `$not_in`- Added the  notin attribute in the where query inside join.
    - `$include`- Include the assoication model `doctors` and `patients`.
    - `$not_between`- Added the notbetween in the  where query inside include .
    - `$not_in`- Added the in attribute in the where query.
    - `$order`- Sort the result based on the order attribute.


  ## => is_nil


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>   "$fields" => ["name", "location", "rating"],
      ...>   "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$where" => %{"rating" => nil},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>     "$include" => ["fat_patients"],
      ...>     "$where" => %{"rating" => %{"$between" => [20, 30]}},
      ...>     "$order" => %{"experience_years" => "$desc"}
      ...>    }
      ...>   },
      ...>  "$right_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"beds" => %{"$in" => [5, 15]}},
      ...>      "$order" => %{"id" => "$asc"}
      ...>     }
      ...>   }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: is_nil(f0.rating) and ^true, where: f1.beds in ^[5, 15] and ^true, order_by: [asc: f1.id], select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating > ^20 and f.rating < ^30 and ^true, order_by: [desc: f.experience_years], limit: ^103, offset: ^0, preload: [:fat_patients]>]>

  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$right_join: :$select`- Select the fields from  `rooms`.
    - `$right_join`- Right join the table `rooms`.
    - `$in`- Added the  in attribute in the where query inside join.
    - `$include`- Include the assoication model `doctors` and `patients`.
    - `$between`- Added the between in the  where query inside include .
    - `nil`- Added the nil attribute in the where query.
    - `$order`- Sort the result based on the order attribute.
    - `$right_join: :$order`- Sort the result based on the order attribute inside join.


  ## => not_null


  ### Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map.


  ### Example

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>   "$fields" => ["name", "location", "rating"],
      ...>   "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$where" => %{"$not_null" => ["total_staff"]},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>     "$include" => ["fat_patients"],
      ...>     "$where" => %{"rating" => %{"$in" => [20, 30]}},
      ...>     "$order" => %{"rating" => "$asc"},
      ...>     "$select" => ["name", "designation", "phone"]
      ...>    }
      ...>   },
      ...>  "$right_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"beds" => nil},
      ...>      "$order" => %{"id" => "$asc"}
      ...>     }
      ...>   }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: not(is_nil(f0.total_staff)) and ^true, where: is_nil(f1.beds) and ^true, order_by: [asc: f1.id], select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating in ^[20, 30] and ^true, order_by: [asc: f.rating], limit: ^103, offset: ^0, select: map(f, [:name, :designation, :phone]), preload: [:fat_patients]>]>



  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$right_join: :$select`- Select the fields from  `rooms`.
    - `$include: :$select`- Select the fields from  `doctors`.
    - `$right_join`- Right join the table `rooms`.
    - `nil`- Added the  nil attribute in the where query inside join.
    - `$include`- Include the assoication model `doctors` and `patients`.
    - `$in`- Added the in attribute in the  where query inside include .
    - `$not_null`- Added the notnil attribute in the where query.
    - `$order`- Sort the result based on the order attribute.
    - `$right_join: :$order`- Sort the result based on the order attribute inside join.



  ## => field


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
      ...>  "$group" => "rating",
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>     "$include" => ["fat_patients"],
      ...>     "$where" => %{"rating" => %{"$gt" => 5}},
      ...>     "$order" => %{"experience_years" => "$desc"},
      ...>     "$select" => ["name", "designation", "phone"]
      ...>    }
      ...>   },
      ...>  "$right_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"beds" => 10},
      ...>      "$order" => %{"id" => "$asc"}
      ...>     }
      ...>   }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: f0.name == ^"saint claire" and ^true, where: f1.beds == ^10 and ^true, group_by: [f0.rating], order_by: [asc: f1.id], select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.rating > ^5 and ^true, order_by: [desc: f.experience_years], limit: ^103, offset: ^0, select: map(f, [:name, :designation, :phone]), preload: [:fat_patients]>]>


  ### Options
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$right_join: :$select`- Select the fields from  `rooms`.
    - `$include: :$select`- Select the fields from  `doctors`.
    - `$right_join`- Right join the table `rooms`.
    - `$include`- Include the assoication model `doctors` and `patients`.
    - `$gt`- Added the greaterthan attribute in the  where query inside include .
    - `$order`- Sort the result based on the order attribute.
    - `$right_join: :$order`- Sort the result based on the order attribute inside join.
    - `$group`- Added the group_by attribute in the query.


  """

  alias FatEcto.FatQuery.{FatDynamics, FatNotDynamics, WhereOr}
  # TODO: Add docs and examples for ex_doc

  @doc """
  Build a  `where query` depending on the params.
  ## Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map
  ## Examples
      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"location" => %{"$not_like" => "%addre %"}},
      ...>  "$group" => "total_staff"
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: not(like(fragment("(?)::TEXT", f.location), ^"%addre %")) and ^true, group_by: [f.total_staff], order_by: [desc: f.id], select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>



  ## Options

    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$where`- Added the where attribute in the query.
    - `$not_like`- Added the notlike attribute in the where query.
    - `$group`- Added the group_by attribute in the query.
    - `$order`- Sort the result based on the order attribute.

  """
  def build_where(queryable, where_params, opts \\ [])

  def build_where(queryable, nil, _opts) do
    queryable
  end

  def build_where(queryable, where_params, opts) do
    # TODO: Add docs and examples of ex_doc for this case here
    queryable = {%{}, queryable}

    {where_params, queryable} =
      Enum.reduce(where_params, queryable, fn {k, v}, {map, queryable} ->
        if String.contains?(k, "$or") do
          {map, WhereOr.or_condition(queryable, where_params[k])}
        else
          {Map.put(map, k, v), queryable}
        end
      end)

    Enum.reduce(where_params, queryable, fn {k, v}, queryable ->
      query_where(queryable, {k, v}, opts)
    end)
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

                %{"$not" => value} ->
                  FatNotDynamics.not_eq_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

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
          dynamics =
            Enum.reduce(map_cond, false, fn {key, condition}, dynamics ->
              case condition do
                %{"$like" => value} ->
                  FatNotDynamics.not_like_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                %{"$ilike" => value} ->
                  FatNotDynamics.not_ilike_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                %{"$lt" => value} ->
                  FatNotDynamics.not_lt_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                %{"$lte" => value} ->
                  FatNotDynamics.not_lte_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                %{"$gt" => value} ->
                  FatNotDynamics.not_gt_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                %{"$gte" => value} ->
                  FatNotDynamics.not_gte_dynamic(key, value, dynamics, opts ++ [dynamic_type: :or])

                condition when not is_list(condition) and not is_map(condition) ->
                  FatNotDynamics.not_eq_dynamic(key, condition, dynamics, opts ++ [dynamic_type: :or])

                _whatever ->
                  dynamics
              end
            end)

          # TODO: confirm its what should be used `where` or `or_where` below

          from(q in queryable, where: ^dynamics)

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
            FatNotDynamics.not_like_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

          "$not_ilike" ->
            FatNotDynamics.not_ilike_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

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

          "$between_equal" ->
            FatDynamics.between_equal_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

          "$not_between" ->
            FatNotDynamics.not_between_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

          "$not_between_equal" ->
            FatNotDynamics.not_between_equal_dynamic(
              k,
              value,
              dynamics,
              opts ++ [dynamic_type: :and]
            )

          "$in" ->
            FatDynamics.in_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

          "$not_in" ->
            FatNotDynamics.not_in_dynamic(k, value, dynamics, opts ++ [dynamic_type: :and])

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
    from(
      q in queryable,
      where: ^FatDynamics.is_nil_dynamic(k, true, opts ++ [dynamic_type: :and])
    )
  end

  # TODO: Add docs and examples of ex_doc for this case here
  # TODO: check if following code is needed
  # $where: {score: 5}
  defp query_where(queryable, {k, map_cond}, opts) when not is_list(map_cond) do
    from(
      q in queryable,
      where: ^FatDynamics.eq_dynamic(k, map_cond, true, opts ++ [dynamic_type: :and])
    )
  end

  # TODO: Add docs and examples of ex_doc for this case here
  # $where: {$not_null: [score, rating]}
  defp query_where(queryable, {k, map_cond}, opts)
       when is_list(map_cond) and k == "$not_null" do
    Enum.reduce(map_cond, queryable, fn key, queryable ->
      from(
        q in queryable,
        where: ^FatNotDynamics.not_is_nil_dynamic(key, true, opts ++ [dynamic_type: :and])
      )
    end)
  end

  # TODO: Add docs and examples of ex_doc for this case here
  # $where: {score: $not_null}
  defp query_where(queryable, {k, map_cond}, opts)
       when map_cond == "$not_null" do
    from(
      q in queryable,
      where: ^FatNotDynamics.not_is_nil_dynamic(k, true, opts ++ [dynamic_type: :and])
    )
  end
end
