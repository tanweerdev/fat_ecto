defmodule FatEcto.FatQuery.FatWhere do
  @moduledoc """
  Where supports multiple query methods.

  ## => like
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map.

  ### Example

    iex> query_opts = %{
    ...>   "$select" => %{"$fields" => ["phone", "designation", "experience_years"]},
    ...>   "$where" => %{"designation" => %{"$like" => "%Joh %"}}
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatDoctor, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatDoctor, where: like(fragment("(?)::TEXT", f0.designation), ^"%Joh %") and ^true, select: map(f0, [:phone, :designation, :experience_years])>

  ### Options
  - `$select`- Select the fields from `doctor`.
  - `$like`- Added the like attribute in the where query.

  ## => iLike
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>   "$select" => %{"$fields" => ["phone", "designation", "experience_years"]},
    ...>   "$where" => %{"designation" => %{"$ilike" => "%surge %"}},
    ...>   "$order" => %{"rating" => "$asc"}
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatDoctor, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatDoctor, where: ilike(fragment("(?)::TEXT", f0.designation), ^"%surge %") and ^true, order_by: [asc: f0.rating], select: map(f0, [:phone, :designation, :experience_years])>

  ### Options
  - `$select`- Select the fields from `doctor`.
  - `$ilike`- Added the ilike attribute in the where query.
  - `$order`- Sort the result based on the order attribute.



  ## => notLike
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>    "$fields" => ["name", "location", "rating"],
    ...>    "fat_rooms" => ["name", "floor"],
    ...>   },
    ...>  "$where" => %{"location" => %{"$not_like" => "%street2 %"}},
    ...>  "$order" => %{"id" => "$desc"}
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, where: not like(fragment(\"(?)::TEXT\", f0.location), ^\"%street2 %\") and ^true, order_by: [desc: f0.id], select: map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]])>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$not_like`- Added the notlike attribute in the where query.
  - `$order`- Sort the result based on the order attribute.



  ## => notILike
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>    "$fields" => ["name", "location", "rating"]
    ...>   },
    ...>  "$where" => %{"location" => %{"$not_ilike" => "%street2 %"}},
    ...>  "$group" => "rating"
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, where: not ilike(fragment(\"(?)::TEXT\", f0.location), ^\"%street2 %\") and ^true, group_by: [f0.rating], select: map(f0, [:name, :location, :rating])>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$not_ilike`- Added the notilike attribute in the where query.
  - `$group`- Added the group_by attribute in the query.




  ## => lessThan
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>    "$select" => %{
    ...>     "$fields" => ["name", "location", "rating"]
    ...>    },
    ...>   "$where" => %{"rating" => %{"$lt" => 4}}
    ...>  }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating < ^4 and ^true, select: map(f0, [:name, :location, :rating])>


  ### Options
  - `$select`- Select the fields from `hospital`.
  - `$lt`- Added the lessthan attribute in the where query.




  ## => lessThan the other field
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>   "$select" => %{
    ...>      "$fields" => ["name", "location", "rating"]
    ...>    },
    ...>    "$where" => %{"total_staff" => %{"$lt" => "$rating"}},
    ...>    "$order" => %{"id" => "$desc"}
    ...>  }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff < f0.rating and ^true, order_by: [desc: f0.id], select: map(f0, [:name, :location, :rating])>

  ### Options
  - `$select`- Select the fields from `hospital`.
  - `$lt: :$field`- Added the lessthan attribute in the where query.
  - `$order`- Sort the result based on the order attribute.




  ## => lessThanEqual
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>   "$select" => %{
    ...>     "$fields" => ["name", "location", "rating"],
    ...>     "fat_rooms" => ["name", "floor"]
    ...>    },
    ...>   "$where" => %{"total_staff" => %{"$lte" => 3}},
    ...>  }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff <= ^3 and ^true, select: map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]])>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$lte`- Added the lessthanequal attribute in the where query.



  ## => lessThanEqual the other field
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>    "$fields" => ["name", "location", "rating"],
    ...>    "fat_rooms" => ["name", "floor"]
    ...>   },
    ...>  "$where" => %{"total_staff" => %{"$lte" => "$rating"}},
    ...>  "$group" => "total_staff"
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff <= f0.rating and ^true, group_by: [f0.total_staff], select: map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]])>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$lte: :$field`- Added the lessthanequal attribute in the where query.
  - `$group`- Added the group_by attribute in the query.



  ## => greaterThan
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["name", "floor"]
    ...>  },
    ...>  "$where" => %{"total_staff" => %{"$gt" => 4}},
    ...>  "$group" => "total_staff",
    ...>  "$order" => %{"rating" => "$desc"}
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff > ^4 and ^true, group_by: [f0.total_staff], order_by: [desc: f0.rating], select: map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]])>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$gt`- Added the lessthan attribute in the where query.
  - `$group`- Added the group_by attribute in the query.
  - `$order`- Sort the result based on the order attribute.




  ## => greaterThan the other field
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["name", "floor"]
    ...>  },
    ...>  "$where" => %{"total_staff" => %{"$gt" => "$rating"}},
    ...>  "$include" => %{
    ...>    "fat_doctors" => %{
    ...>      "$where" => %{"rating" => %{"$lt" => 3}},
    ...>      "$order" => %{"id" => "$desc"}
    ...>    }
    ...>   }
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, left_join: f1 in assoc(f0, :fat_doctors), where: f0.total_staff > f0.rating and ^true, where: f1.rating < ^3 and ^true, order_by: [desc: f1.id], limit: ^34, offset: ^0, select: map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]]), preload: [:fat_doctors]>


  ### Options
  - `$select`- Select the fields from `hospital`.
  - `$gt: :$field`- Added the greaterthan attribute in the where query.
  - `$include`- Include the assoication model `doctors`.
  - `$lt`- Added the lessthan attribute in the where query inside include.



  ## => greaterThanEqual
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["name", "floor"]
    ...>  },
    ...>  "$where" => %{"total_staff" => %{"$gte" => 5}},
    ...>  "$include" => %{
    ...>   "fat_doctors" => %{
    ...>    "$where" => %{"rating" => %{"$lte" => 3}},
    ...>   }
    ...>  }
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, left_join: f1 in assoc(f0, :fat_doctors), where: f0.total_staff >= ^5 and ^true, where: f0.rating <= ^3 and ^true, limit: ^34, offset: ^0, select: map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]]), preload: [:fat_doctors]>


  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$gte`- Added the greaterthanequal attribute in the where query.
  - `$include`- Include the assoication model `doctors`.
  - `$lte`- Added the lessthanequal attribute in the where query inside include.





  ## => greaterThanEqual the other field
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>    "$fields" => ["name", "location", "rating"],
    ...>    "fat_rooms" => ["name", "floor"]
    ...>   },
    ...>  "$where" => %{"rating" => %{"$gte" => "$total_staff"}},
    ...>  "$include" => %{
    ...>    "fat_doctors" => %{
    ...>      "$where" => %{"rating" => %{"$gte" => 3}},
    ...>      "$order" => %{"rating" => "$asc"}
    ...>     }
    ...>   }
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, left_join: f1 in assoc(f0, :fat_doctors), where: f0.rating >= f0.total_staff and ^true, where: f1.rating >= ^3 and ^true, order_by: [asc: f1.rating], limit: ^34, offset: ^0, select: map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]]), preload: [:fat_doctors]>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$gte: :$field`- Added the  greaterthanequal attribute in the where query.
  - `$include`- Include the assoication model `doctors`.
  - `$gte`- Added the greaterthanequal attribute in the where query inside include.
  - `$order`- Sort the result based on the order attribute.


  ## => between
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["name", "floor"]
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
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, left_join: f1 in assoc(f0, :fat_doctors), where: f0.rating > ^10 and f0.rating < ^20 and ^true, where: f1.rating >= f1.total_staff and ^true, order_by: [asc: f1.rating], limit: ^34, offset: ^0, select: map(f0, [:name, :location, :rating, {:fat_rooms, [:name, :floor]}]), preload: [[fat_doctors: [:fat_patients]]]>

  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$between: :$field`- Added the  between attribute in the where query.
  - `$include`- Include the assoication model `doctors` and `patients`.
  - `$gte`- Added the greaterthanequal attribute in the where query inside include.
  - `$order`- Sort the result based on the order attribute.

  ## => not_between
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...> "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["name", "floor"]
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
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, left_join: f1 in assoc(f0, :fat_doctors), where: (f0.rating < ^10 or f0.rating > ^20) and ^true, where: f1.rating > ^20 and f1.rating < ^30 and ^true, order_by: [asc: f1.experience_years], limit: ^34, offset: ^0, select: map(f0, [:name, :location, :rating, {:fat_rooms, [:name, :floor]}]), preload: [[fat_doctors: [:fat_patients]]]>


  ### Options
  - `$select`- Select the fields from `hospital` and `rooms`.
  - `$not_between: :$field`- Added the  notbetween attribute in the where query.
  - `$include`- Include the assoication model `doctors` and `patients`.
  - `$between`- Added the between attribute in the where query inside include.
  - `$order`- Sort the result based on the order attribute.



  ## => in
  ### Parameters

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>   "$select" => %{
    ...>    "$fields" => ["name", "location", "rating"],
    ...>    "fat_rooms" => ["name", "floor"]
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
    ...>      "$select" => ["name", "purpose", "floor"],
    ...>      "$where" => %{"floor" => %{"$gte" => 2}}
    ...>    }
    ...>   }
    ...>  }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in \"fat_rooms\", on: f0.id == f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.rating in ^[10, 20] and ^true, where: f1.floor >= ^2 and ^true, where: (f2.rating < ^20 or f2.rating > ^30) and ^true, order_by: [asc: f2.experience_years], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]]), %{\n  ^\"fat_rooms\" => map(f1, [:name, :purpose, :floor])\n}), preload: [fat_doctors: [:fat_patients]]>

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

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["name", "floor"]
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
    ...>      "$select" => ["name", "floor", "is_active"],
    ...>      "$where" => %{"floor" => %{"$not_in" => [5, 15]}}
    ...>     }
    ...>   }
    ...>  }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.rating not in ^[10, 20] and ^true, where: f1.floor not in ^[5, 15] and ^true, where: (f2.rating < ^20 or f2.rating > ^30) and ^true, order_by: [desc: f2.rating], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:name, :floor]}]), %{^"fat_rooms" => map(f1, [:name, :floor, :is_active])}), preload: [[fat_doctors: [:fat_patients]]]>

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

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["floor", "name"]
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
    ...>      "$select" => ["name", "floor", "is_active"],
    ...>      "$where" => %{"floor" => %{"$in" => [5, 15]}},
    ...>      "$order" => %{"id" => "$asc"}
    ...>     }
    ...>   }
    ...>  }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in \"fat_rooms\", on: f0.id == f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: is_nil(f0.rating) and ^true, where: f1.floor in ^[5, 15] and ^true, where: f2.rating > ^20 and f2.rating < ^30 and ^true, order_by: [asc: f1.id], order_by: [desc: f2.experience_years], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:floor, :name]}]), %{^\"fat_rooms\" => map(f1, [:name, :floor, :is_active])}), preload: [[fat_doctors: [:fat_patients]]]>

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

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map


  ### Example

    iex> query_opts = %{
    ...>  "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["name", "floor"]
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
    ...>      "$select" => ["name", "floor", "is_active"],
    ...>      "$where" => %{"name" => nil},
    ...>      "$order" => %{"id" => "$asc"}
    ...>     }
    ...>   }
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in \"fat_rooms\", on: f0.id == f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: not is_nil(f0.total_staff) and ^true, where: is_nil(f1.name) and ^true, where: f2.rating in ^[20, 30] and ^true, order_by: [asc: f1.id], order_by: [asc: f2.rating], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]]), %{\n  ^\"fat_rooms\" => map(f1, [:name, :floor, :is_active])\n}), preload: [fat_doctors: [:fat_patients]]>


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

  - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
  - `query_opts`  - Include query options as a map

  ### Example

    iex> query_opts = %{
    ...> "$select" => %{
    ...>   "$fields" => ["name", "location", "rating"],
    ...>   "fat_rooms" => ["name", "floor"]
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
    ...>      "$select" => ["floor", "name", "is_active"],
    ...>      "$where" => %{"floor" => 10},
    ...>      "$order" => %{"id" => "$asc"}
    ...>     }
    ...>   }
    ...> }
    iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
    #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in \"fat_rooms\", on: f0.id == f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.name == ^\"saint claire\" and ^true, where: f1.floor == ^10 and ^true, where: f2.rating > ^5 and ^true, group_by: [f0.rating], order_by: [asc: f1.id], order_by: [desc: f2.experience_years], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, fat_rooms: [:name, :floor]]), %{\n  ^\"fat_rooms\" => map(f1, [:floor, :name, :is_active])\n}), preload: [fat_doctors: [:fat_patients]]>

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

  import Ecto.Query
  alias FatEcto.FatQuery.{FatDynamics, FatNotDynamics, WhereOr}

  @doc """
  Build a  `where query` depending on the params.
  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Include query options as a map

  ### Examples

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["name", "floor"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"location" => %{"$not_like" => "%addre %"}},
      ...>  "$group" => "total_staff"
      ...> }
      iex> #{MyApp.Query}.build!(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: not(like(fragment(\"(?)::TEXT\", f0.location), ^\"%addre %\")) and ^true, group_by: [f0.total_staff], order_by: [desc: f0.id], select: map(f0, [:name, :location, :rating, {:fat_rooms, [:name, :floor]}])>

  ## Options

    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$where`- Added the where attribute in the query.
    - `$not_like`- Added the notlike attribute in the where query.
    - `$group`- Added the group_by attribute in the query.
    - `$order`- Sort the result based on the order attribute.

  """
  alias FatEcto.FatHelper

  @spec build_where(Ecto.Queryable.t(), map() | keyword(), map() | keyword(), keyword()) :: Ecto.Query.t()
  def build_where(queryable, where_params, build_options, opts \\ [])

  def build_where(queryable, nil, _opts, _build_options) do
    queryable
  end

  def build_where(queryable, where_params, build_options, opts) do
    queryable = {%{}, queryable}

    {where_params, queryable} =
      Enum.reduce(where_params, queryable, fn {k, v}, {map, queryable} ->
        # TODO: why contains
        if String.contains?(k, "$or") do
          {map, WhereOr.or_condition(queryable, where_params[k], build_options, opts)}
        else
          {Map.put(map, k, v), queryable}
        end
      end)

    dynamics =
      Enum.reduce(where_params, true, fn {k, v}, dynamics ->
        query_where(dynamics, {k, v}, opts)
      end)

    from(q in queryable, where: ^dynamics)
  end

  # TODO: Add docs and examples of ex_doc for this case here
  defp query_where(dynamics, {k, map_cond}, opts) when is_map(map_cond) do
    # TODO: dynamics not being assigned??
    dynamics =
      case k do
        "$or" ->
          Enum.reduce(map_cond, dynamics, fn {key, condition}, dynamics ->
            field = FatHelper.string_to_existing_atom(key)

            case condition do
              %{"$like" => value} ->
                dynamics and FatDynamics.like_dynamic(field, value, opts)

              %{"$ilike" => value} ->
                dynamics and FatDynamics.ilike_dynamic(field, value, opts)

              %{"$lt" => value} ->
                dynamics and FatDynamics.lt_dynamic(field, value, opts)

              %{"$not" => value} ->
                dynamics and FatNotDynamics.not_eq_dynamic(field, value, opts)

              %{"$not_equal" => value} ->
                dynamics and FatNotDynamics.not_eq_dynamic(field, value, opts)

              %{"$equal" => value} ->
                dynamics and FatNotDynamics.eq_dynamic(field, value, opts)

              %{"$lte" => value} ->
                dynamics and FatDynamics.lte_dynamic(field, value, opts)

              %{"$gt" => value} ->
                dynamics and FatDynamics.gt_dynamic(field, value, opts)

              %{"$gte" => value} ->
                dynamics and FatDynamics.gte_dynamic(field, value, opts)

              condition when not is_list(condition) and not is_map(condition) ->
                dynamics and FatDynamics.eq_dynamic(field, condition, opts)

              _whatever ->
                dynamics
            end
          end)

        # TODO: confirm its what should be used `where` or `or_where` below

        "$not" ->
          Enum.reduce(map_cond, dynamics, fn {key, condition}, dynamics ->
            field = FatHelper.string_to_existing_atom(key)

            case condition do
              %{"$like" => value} ->
                dynamics and
                  FatNotDynamics.not_like_dynamic(field, value, opts)

              %{"$ilike" => value} ->
                dynamics and
                  FatNotDynamics.not_ilike_dynamic(field, value, opts)

              %{"$lt" => value} ->
                dynamics and FatNotDynamics.not_lt_dynamic(field, value, opts)

              %{"$equal" => value} ->
                dynamics and FatDynamics.eq_dynamic(field, value, opts)

              %{"$lte" => value} ->
                dynamics and FatNotDynamics.not_lte_dynamic(field, value, opts)

              %{"$gt" => value} ->
                dynamics and FatNotDynamics.not_gt_dynamic(field, value, opts)

              %{"$gte" => value} ->
                dynamics and FatNotDynamics.not_gte_dynamic(field, value, opts)

              condition when not is_list(condition) and not is_map(condition) ->
                dynamics and FatNotDynamics.not_eq_dynamic(field, condition, opts)

              _whatever ->
                dynamics
            end
          end)

        # TODO: confirm its what should be used `where` or `or_where` below

        _whatever ->
          dynamics
      end

    Enum.reduce(map_cond, dynamics, fn {key, value}, dynamics ->
      field = FatHelper.string_to_existing_atom(k)

      case key do
        "$like" ->
          dynamics and FatDynamics.like_dynamic(field, value, opts)

        "$ilike" ->
          dynamics and FatDynamics.ilike_dynamic(field, value, opts)

        "$array_ilike" ->
          dynamics and FatDynamics.array_ilike_dynamic(field, value, opts)

        "$not_like" ->
          dynamics and FatNotDynamics.not_like_dynamic(field, value, opts)

        "$not_ilike" ->
          dynamics and FatNotDynamics.not_ilike_dynamic(field, value, opts)

        "$lt" ->
          dynamics and FatDynamics.lt_dynamic(field, value, opts)

        "$lte" ->
          dynamics and FatDynamics.lte_dynamic(field, value, opts)

        "$gt" ->
          dynamics and FatDynamics.gt_dynamic(field, value, opts)

        "$gte" ->
          dynamics and FatDynamics.gte_dynamic(field, value, opts)

        "$between" ->
          dynamics and FatDynamics.between_dynamic(field, value, opts)

        "$between_equal" ->
          dynamics and FatDynamics.between_equal_dynamic(field, value, opts)

        "$not_between" ->
          dynamics and FatNotDynamics.not_between_dynamic(field, value, opts)

        "$not_between_equal" ->
          dynamics and FatNotDynamics.not_between_equal_dynamic(field, value, opts)

        "$in" ->
          dynamics and FatDynamics.in_dynamic(field, value, opts)

        "$not_in" ->
          dynamics and FatNotDynamics.not_in_dynamic(field, value, opts)

        "$contains" ->
          dynamics and FatDynamics.contains_dynamic(field, value, opts)

        "$contains_any" ->
          dynamics and FatDynamics.contains_any_dynamic(field, value, opts)

        "$not_equal" ->
          dynamics and FatDynamics.not_eq_dynamic(field, value, opts)

        "$equal" ->
          dynamics and FatDynamics.eq_dynamic(field, value, opts)

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
          dynamics

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
          dynamics

        _ ->
          # TODO:
          dynamics
      end
    end)
  end

  # TODO: Add docs and examples of ex_doc for this case here
  # $where: {score == nil}
  defp query_where(dynamics, {k, map_cond}, opts) when is_nil(map_cond) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics and FatDynamics.nil_dynamic?(field, opts)
  end

  # TODO: Add docs and examples of ex_doc for this case here
  # $where: {score: $not_null}

  defp query_where(dynamics, {k, map_cond}, opts)
       when map_cond == "$not_null" do
    field = FatHelper.string_to_existing_atom(k)
    dynamics and FatNotDynamics.not_nil_dynamic?(field, opts)
  end

  defp query_where(dynamics, {k, map_cond}, opts) when not is_list(map_cond) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics and FatDynamics.eq_dynamic(field, map_cond, opts)
  end

  # TODO: Add docs and examples of ex_doc for this case here
  # $where: {$not_null: [score, rating]}
  defp query_where(dynamics, {k, map_cond}, opts)
       when is_list(map_cond) and k == "$not_null" do
    Enum.reduce(map_cond, dynamics, fn key, dynamics ->
      field = FatHelper.string_to_existing_atom(key)
      dynamics and FatNotDynamics.not_nil_dynamic?(field, opts)
    end)
  end

  defp query_where(dynamics, {k, map_cond}, opts)
       when is_list(map_cond) do
    field = FatHelper.string_to_existing_atom(k)
    dynamics and FatDynamics.eq_dynamic(field, map_cond, opts)
  end
end
