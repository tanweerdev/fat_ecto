# FatEcto

[![Coverage Status](https://coveralls.io/repos/github/tanweerdev/fat_ecto/badge.svg?branch=master)](https://coveralls.io/github/tanweerdev/fat_ecto?branch=master)

## Description

FAT provides methods for _dynamically_ building queries depending on the parameters it receive.

Currently it's supporting following **query functions**:

- where
- select
- joins
- order_by
- include
- group_by

## Installation

#### you can get latest from github or published version from hex

```elixir
{:fat_ecto, github: "tanweerdev/fat_ecto"}
or
{:fat_ecto, "~> 0.1"}
```

#### Please do not pass custom $join type for associations which are related via has_many or many_to_many eg
```elixir
# Please dont pass join like below to avoid un-expected/duplicated records
"$include": %{"doctors" => %{"$join" => "left"}}
# correct way
"$include": %{"doctors" => %{}}
```

## Config

```elixir
config :my_app, :fat_ecto,
  repo: ExApi.Repo,
  default_limit: 10,
  max_limit: 100
```

## Usage

Once installed you can _use_ **FatEcto.FatQuery** inside your module and use the `build method`. Which is the entry method for building every query. And also the main method for the **FatEcto.FatQuery**.

```elixir
build(schema_name, params)
```

#### Example

```eliixir
defmodule MyApp.Query do
  use FatEcto.FatQuery, otp_app: :my_app, max_limit: 103, default_limit: 34
end

import MyApp.Query
query_opts = %{
      "$select" => %{
        "$fields" => ["name", "location", "rating"],
        "fat_rooms" => ["beds", "capacity"]
      },
      "$order" => %{"id" => "$desc"},
      "$where" => %{"rating" => 4},
      "$group" => ["total_staff", "rating"],
      "$include" => %{
        "fat_doctors" => %{
          "$include" => ["fat_patients"],
          "$where" => %{"name" => "ham"},
          "$order" => %{"id" => "$desc"},
          "$join" => "$right"
        }
      },
      "$right_join" => %{
        "fat_rooms" => %{
          "$on_field" => "id",
          "$on_table_field" => "hospital_id",
          "$select" => ["beds", "capacity", "level"],
          "$where" => %{"incharge" => "John"},
          "$order" => %{"level" => "$asc"}
        }
      }
    }
iex> build(FatEcto.FatHospital, query_opts)
iex> #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms",
     on: f0.id == f1.hospital_id, right_join: f2 in assoc(f0, :fat_doctors),
     where: f0.rating == ^4 and ^true, where: f1.incharge == ^"John" and ^true,
     group_by: [f0.total_staff], group_by: [f0.rating], order_by: [asc: f1.level],
     order_by: [desc: f0.id],
     select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]),
     %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}),
     preload: [fat_doctors: #Ecto.Query<from f0 in FatEcto.FatDoctor,
     left_join: f1 in assoc(f0, :fat_patients),
     where: f0.name == ^"ham" and ^true, order_by: [desc: f0.id],
     limit: ^10, offset: ^0, preload: [:fat_patients]>]>
```

##### Options:

These are the options supported

| Option                  | Description                                                              |
| ----------------------- | ------------------------------------------------------------------------ |
| $include                | Include the assoication model `doctors`                                  |
| $include: :fat_patients | Include the assoication `patients`. Which has association with `doctors` |
| $select                 | Select the fields from `hospital` and `rooms`                            |
| $where                  | Added the where attribute in the query                                   |
| $group                  | Added the group_by attribute in the query as a list                      |
| $order                  | Sort the result based on the order attribute                             |
| $right_join             | Specify the type of join                                                 |
| $on_field               | Specify the field for join                                               |
| $on_table_field    | Specify the field for join in the joining table                          |

see [Docs](https://hexdocs.pm/fat_ecto/) for more details.
