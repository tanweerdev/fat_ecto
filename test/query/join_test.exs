# defmodule Query.JoinTest do
#   use FatEcto.ConnCase

#   setup do
#     hospital = insert(:hospital)
#     insert(:room, fat_hospital_id: hospital.id)
#     Application.delete_env(:fat_ecto, :fat_ecto, [:blacklist_params])

#     :ok
#   end

#   test "returns the query with right join and selected fields" do
#     opts = %{
#       "$select" => ["name", "location"],
#       "$right_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "fat_hospital_id",
#           "$on_table" => "fat_rooms",
#           "$select" => ["name", "purpose"],
#           "$where" => %{"name" => "room 1"}
#         }
#       }
#     }

#     expected =
#       from(
#         h in "fat_hospitals",
#         right_join: r in "fat_rooms",
#         on: h.id == r.fat_hospital_id,
#         where: r.name == ^"room 1" and ^true,
#         select: merge(map(h, [:name, :location]), %{^"fat_rooms" => map(r, [:name, :purpose])})
#       )

#     # opts = %{
#     #   "$right_join" => %{
#     #     "fat_rooms" => %{
#     #       "$on_field" => "id",
#     #       "$on_table_field" => "fat_hospital_id",
#     #       "$select" => ["name", "purpose", "description"],
#     #       "$where" => %{"name" => "room 1"}
#     #     }
#     #   }
#     # }

#     # expected =
#     #   from(
#     #     h in FatEcto.FatHospital,
#     #     right_join: r in "fat_rooms",
#     #     on: h.id == r.fat_hospital_id,
#     #     where: r.name == ^"room 1" and ^true,
#     #     select: merge(h, %{^:fat_rooms => map(r, [:name, :purpose, :description])})
#     #   )

#     query = Query.build!("fat_hospitals", opts)

#     assert inspect(query) == inspect(expected)
#     # TODO: match on results returned
#     Repo.all(query)
#   end

#   test "returns the query with left join and selected fields" do
#     opts = %{
#       "$right_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         right_join: r in "fat_rooms",
#         on: h.id == r.hospital_id,
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with full join and selected fields" do
#     opts = %{
#       "$select" => %{"$fields" => ["designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$select" => ["name", "prescription", "symptoms"]
#         }
#       }
#     }

#     expected =
#       from(
#         d in FatEcto.FatDoctor,
#         full_join: p in "fat_patients",
#         on: d.id == p.doctor_id,
#         select:
#           merge(map(d, [:designation, :experience_years]), %{
#             ^"fat_patients" => map(p, [:name, :prescription, :symptoms])
#           })
#       )

#     result = Query.build!(FatEcto.FatDoctor, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on: h.id == r.hospital_id,
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and additional on clause $in" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "rating" => %{"$in" => [1, 2, 3]}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on: h.id == r.hospital_id and (h.rating in ^[1, 2, 3] and ^true),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and in/between additional on clauses" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "rating" => %{"$in" => [1, 2, 3]},
#             "total_staff" => %{"$between" => [1, 3]}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on:
#           h.id == r.hospital_id and
#             (h.total_staff > ^1 and h.total_staff < ^3 and (h.rating in ^[1, 2, 3] and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and gte/lt additional on clauses" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "total_staff" => %{"$gte" => 1},
#             "rating" => %{"$lt" => 5}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on: h.id == r.hospital_id and (h.total_staff >= ^1 and (h.rating < ^5 and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and gt/lte additional on clauses" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "rating" => %{"$gt" => 3},
#             "total_staff" => %{"$lte" => 1}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on: h.id == r.hospital_id and (h.total_staff <= ^1 and (h.rating > ^3 and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and like/ilike additional on clauses" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "name" => %{"$like" => "%Joh%"},
#             "location" => %{"$ilike" => "%Dev"}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on:
#           h.id == r.hospital_id and
#             (like(fragment("(?)::TEXT", h.name), ^"%Joh%") and
#                (ilike(fragment("(?)::TEXT", h.location), ^"%Dev") and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and notlike/not_ilike additional on clauses" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "name" => %{"$not_like" => "%Joh%"},
#             "location" => %{"$not_ilike" => "%Dev"}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on:
#           h.id == r.hospital_id and
#             (not like(fragment("(?)::TEXT", h.name), ^"%Joh%") and
#                (not ilike(fragment("(?)::TEXT", h.location), ^"%Dev") and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and notlike/not_ilike additional on clauses on joining table" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "purpose" => %{"$not_like" => "%Treat%", "$binding" => "last"},
#             "location" => %{"$not_ilike" => "%Dev"}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on:
#           h.id == r.hospital_id and
#             (not like(fragment("(?)::TEXT", r.purpose), ^"%Treat%") and
#                (not ilike(fragment("(?)::TEXT", h.location), ^"%Dev") and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and notlike/not_ilike mutiple additional clauses on join table" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "purpose" => %{"$not_like" => "%Treat%", "$binding" => "last"},
#             "name" => %{"$not_ilike" => "%Dev", "$binding" => "last"}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on:
#           h.id == r.hospital_id and
#             (not like(fragment("(?)::TEXT", r.purpose), ^"%Treat%") and
#                (not ilike(fragment("(?)::TEXT", r.name), ^"%Dev") and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and not_between/not_betweenequal additional on clauses" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "rating" => %{"$not_between" => [1, 3]},
#             "total_staff" => %{"$not_between_equal" => [4, 5]}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on:
#           h.id == r.hospital_id and
#             ((h.total_staff <= ^4 or h.total_staff >= ^5) and ((h.rating < ^1 or h.rating > ^3) and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and not_in/equal additional on clauses" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "rating" => %{"$not_in" => [1, 3]},
#             "total_staff" => %{"$equal" => 3}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on: h.id == r.hospital_id and (h.total_staff == ^3 and (h.rating not in ^[1, 3] and ^true)),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and additional on clause $between" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$additional_on_clauses" => %{
#             "rating" => %{"$between_equal" => [1, 3]}
#           },
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on: h.id == r.hospital_id and (h.rating >= ^1 and h.rating <= ^3 and ^true),
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and inner where" do
#     opts = %{
#       "$inner_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         inner_join: r in "fat_rooms",
#         on: h.id == r.hospital_id,
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)
#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with inner join and selected fields and outer where" do
#     opts = %{
#       "$right_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         right_join: r in "fat_rooms",
#         on: h.id == r.hospital_id,
#         where: r.incharge == ^"John" and ^true,
#         select: %{^"fat_rooms" => map(r, [:beds, :capacity, :level])}
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)

#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with multiple inner joins and selected fields and outer where" do
#     opts = %{
#       "$right_join" => %{
#         "fat_rooms" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$select" => ["beds", "capacity", "level"],
#           "$where" => %{"incharge" => "John"}
#         },
#         "fat_doctors" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "hospital_id",
#           "$select" => ["phone", "address"],
#           "$where" => %{"rating" => 5}
#         }
#       },
#       "$where" => %{"rating" => 3}
#     }

#     expected =
#       from(
#         h in FatEcto.FatHospital,
#         where: h.rating == ^3 and ^true,
#         right_join: d in "fat_doctors",
#         on: h.id == d.hospital_id,
#         right_join: r in "fat_rooms",
#         on: h.id == r.hospital_id,
#         where: d.rating == ^5 and ^true,
#         where: r.incharge == ^"John" and ^true,
#         select:
#           merge(%{^"fat_doctors" => map(d, [:phone, :address])}, %{
#             ^"fat_rooms" => map(r, [:beds, :capacity, :level])
#           })
#       )

#     result = Query.build!(FatEcto.FatHospital, opts)

#     assert inspect(result) == inspect(expected)
#   end

#   test "returns the query with full join and selected fields with blacklist params" do
#     Application.put_env(:fat_ecto, :fat_ecto,
#       blacklist_params: [{:fat_doctors, ["name", "prescription"]}, {:fat_beds, ["is_active"]}]
#     )

#     opts = %{
#       "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$select" => ["name", "prescription", "symptoms"]
#         }
#       }
#     }

#     assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatDoctor, opts) end
#   end

#   test "returns the query with full join with blacklist on_field" do
#     Application.put_env(:fat_ecto, :fat_ecto,
#       blacklist_params: [{:fat_doctors, ["id"]}, {:fat_beds, ["is_active"]}]
#     )

#     opts = %{
#       "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$select" => ["name", "prescription", "symptoms"]
#         }
#       }
#     }

#     assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatDoctor, opts) end
#   end

#   test "returns the query with full join with blacklist on_table_field" do
#     Application.put_env(:fat_ecto, :fat_ecto,
#       blacklist_params: [{:fat_doctors, ["example"]}, {:fat_patients, ["doctor_id"]}]
#     )

#     opts = %{
#       "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$select" => ["name", "prescription", "symptoms"]
#         }
#       }
#     }

#     assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatDoctor, opts) end
#   end

#   test "returns the query with full join with blacklist additional on clauses" do
#     Application.put_env(:fat_ecto, :fat_ecto,
#       blacklist_params: [{:fat_doctors, ["example"]}, {:fat_patients, ["appointments_count"]}]
#     )

#     opts = %{
#       "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$additional_on_clauses" => %{
#             "appointments_count" => %{"$in" => [1, 2, 3]}
#           },
#           "$select" => ["name", "prescription", "symptoms"]
#         }
#       }
#     }

#     assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatDoctor, opts) end
#   end

#   test "returns the query with full join with blacklist where inside join table" do
#     Application.put_env(:fat_ecto, :fat_ecto,
#       blacklist_params: [{:fat_doctors, ["example"]}, {:fat_patients, ["location"]}]
#     )

#     opts = %{
#       "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$where" => %{"location" => "bullavard"},
#           "$select" => ["name", "prescription", "symptoms"]
#         }
#       }
#     }

#     assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatDoctor, opts) end
#   end

#   test "returns the query with full join with blacklist select inside join table" do
#     Application.put_env(:fat_ecto, :fat_ecto,
#       blacklist_params: [{:fat_doctors, ["example"]}, {:fat_patients, ["symptoms"]}]
#     )

#     opts = %{
#       "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$where" => %{"location" => "bullavard"},
#           "$select" => ["name", "prescription", "symptoms"]
#         }
#       }
#     }

#     assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatDoctor, opts) end
#   end

#   test "returns the query with full join with blacklist order inside join table" do
#     Application.put_env(:fat_ecto, :fat_ecto,
#       blacklist_params: [{:fat_doctors, ["example"]}, {:fat_patients, ["appointments_count"]}]
#     )

#     opts = %{
#       "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$where" => %{"location" => "bullavard"},
#           "$select" => ["name", "prescription"],
#           "$order" => %{"appointments_count" => "$asc"}
#         }
#       }
#     }

#     assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatDoctor, opts) end
#   end

#   test "returns the query with full join with blacklist group inside join table" do
#     Application.put_env(:fat_ecto, :fat_ecto,
#       blacklist_params: [{:fat_doctors, ["example"]}, {:fat_patients, ["date_of_birth", "some"]}]
#     )

#     opts = %{
#       "$select" => %{"$fields" => ["name", "designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$where" => %{"location" => "bullavard"},
#           "$select" => ["name", "prescription"],
#           "$order" => %{"appointments_count" => "$asc"},
#           "$group" => "date_of_birth"
#         }
#       }
#     }

#     assert_raise ArgumentError, fn -> Query.build!(FatEcto.FatDoctor, opts) end
#   end

#   test "returns the query with full join and mutiple where conditions" do
#     opts = %{
#       "$select" => %{"$fields" => ["designation", "experience_years"]},
#       "$full_join" => %{
#         "fat_patients" => %{
#           "$on_field" => "id",
#           "$on_table_field" => "doctor_id",
#           "$where" => %{"location" => "bullavard", "phone" => %{"$ilike" => "Joh"}, "symptoms" => "$not_null"},
#           "$select" => ["name", "prescription"],
#           "$order" => %{"appointments_count" => "$asc"}
#         }
#       }
#     }

#     expected =
#       from(f0 in FatEcto.FatDoctor,
#         full_join: f1 in "fat_patients",
#         on: f0.id == f1.doctor_id,
#         where:
#           not is_nil(f1.symptoms) and
#             (ilike(fragment("(?)::TEXT", f1.phone), ^"Joh") and (f1.location == ^"bullavard" and ^true)),
#         order_by: [asc: f1.appointments_count],
#         select:
#           merge(map(f0, [:designation, :experience_years]), %{
#             ^"fat_patients" => map(f1, [:name, :prescription])
#           })
#       )

#     assert inspect(Query.build!(FatEcto.FatDoctor, opts)) == inspect(expected)
#   end
# end
