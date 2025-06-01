# FatEcto: Supercharge Your Ecto Queries with Ease! 🚀

[![Build Status](https://github.com/tanweerdev/fat_ecto/actions/workflows/fat_ecto.yml/badge.svg)](https://github.com/tanweerdev/fat_ecto/actions)
[![Coverage Status](https://coveralls.io/repos/github/tanweerdev/fat_ecto/badge.svg)](https://coveralls.io/github/tanweerdev/fat_ecto)
[![hex.pm version](https://img.shields.io/hexpm/v/fat_ecto.svg)](https://hex.pm/packages/fat_ecto)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/fat_ecto.svg)](https://hex.pm/packages/fat_ecto)
[![hex.pm license](https://img.shields.io/hexpm/l/fat_ecto.svg)](https://github.com/tanweerdev/fat_ecto/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/tanweerdev/fat_ecto.svg)](https://github.com/tanweerdev/fat_ecto/commits/master)

---

## Description

FatEcto is an Elixir package designed to make your life easier when working with Ecto. It simplifies query building, filtering, sorting, and pagination—so you can focus on what truly matters: building amazing applications. With FatEcto, writing complex repeating queries becomes effortless, flexible, and powerful! 💪

---

## Installation

Add `fat_ecto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # Check https://hexdocs.pm/fat_ecto for the latest version
    {:fat_ecto, "~> 1.2"}
  ]
end
```

Then, run `mix deps.get` to install the package.

---

## Features & Modules

### 🛠 FatEcto.Query.Dynamics.Buildable – Dynamic Filtering Made Easy

Tired of writing repetitive query filters? The `Whereable` module lets you dynamically filter records using flexible conditions passed from your web or mobile clients—with little to no effort! And the best part? You stay in control. 🚀

#### Usage

```elixir
defmodule FatEcto.HospitalDynamicsBuilder do
  use FatEcto.Query.Dynamics.Buildable,
    filterable: [
      id: ["$EQUAL", "$NOT_EQUAL"]
    ],
    overrideable: ["name", "phone"],
    ignoreable: [
      name: ["%%", "", [], nil],
      phone: ["%%", "", [], nil]
    ]

  import Ecto.Query

  @impl true
  # You can implement override_buildable for your custom filters
  def override_buildable(_dynamics, "name", "$ILIKE", value) do
    dynamic([r], ilike(fragment("(?)::TEXT", r.name), ^value))
  end

  def override_buildable(dynamics, _field, _operator, _value), do: dynamics
end
```

---

#### Example Usage

Here are some practical examples of how to use `FatEcto.HospitalDynamicsBuilder` to dynamically build queries:

##### Example 1: Basic Filtering by ID

```elixir
# Filter hospitals with ID equal to 1
params = %{"id" => %{"$EQUAL" => 1}}
dynamics = FatEcto.HospitalDynamicsBuilder.build(params)

# Use the dynamics in a query
import Ecto.Query
query = where(FatEcto.FatHospital, ^dynamics)

# Resulting query:
# from(h in FatEcto.FatHospital, where: h.id == 1)
```

##### Example 2: Case-Insensitive Name Search

```elixir
# Filter hospitals with names containing "St. Mary"
params = %{"name" => %{"$ILIKE" => "%St. Mary%"}}
dynamics = FatEcto.HospitalDynamicsBuilder.build(params)

# Use the dynamics in a query
import Ecto.Query
query = where(FatEcto.FatHospital, ^dynamics)

# Resulting query:
# from(h in FatEcto.FatHospital, where: ilike(fragment("(?)::TEXT", h.name), ^"%St. Mary%"))
```

##### Example 3: Combining Multiple Filters

```elixir
# Filter hospitals with ID not equal to 2 AND name containing "General"
params = %{
  "id" => %{"$NOT_EQUAL" => 2},
  "name" => %{"$ILIKE" => "%General%"}
}
dynamics = FatEcto.HospitalDynamicsBuilder.build(params)

# Use the dynamics in a query
import Ecto.Query
query = where(FatEcto.FatHospital, ^dynamics)

# Resulting query:
# from(h in FatEcto.FatHospital, where: h.id != 2 and ilike(fragment("(?)::TEXT", h.name), ^"%General%"))
```

##### Example 4: Ignoring Empty or Invalid Values

```elixir
# Filter hospitals with a name, but ignore empty or invalid values
params = %{"name" => %{"$ILIKE" => "%%"}}  # Empty value is ignored
dynamics = FatEcto.HospitalDynamicsBuilder.build(params)

# Use the dynamics in a query
import Ecto.Query
query = where(FatEcto.FatHospital, ^dynamics)

# Resulting query:
# from(h in FatEcto.FatHospital)  # No filtering applied for name
```

##### Example 5: Even Complex Nested conditions

```elixir
# Filter hospitals with a name, but ignore empty or invalid values
params = %{
  "$OR" => [
    %{
      "name" => %{"$ILIKE" => "%John%"},
      "$OR" => %{"rating" => %{"$GT" => 18}, "location" => "New York"}
    },
    %{
      "start_date" => "2023-01-01",
      "$AND" => [
        %{"rating" => %{"$GT" => 4}},
        %{"email" => "fat_ecto@example.com"}
      ]
    }
  ]
}

dynamics = DoctorFilter.build(params)

# Resulting dynamic:
dynamic(
  [q],
  ((q.location == ^"New York" or q.rating > ^18) and ilike(fragment("(?)::TEXT", q.name), ^"%John%")) or
    (q.rating > ^4 and q.email == ^"fat_ecto@example.com" and q.start_date == ^"2023-01-01")
)

# You can now apply the result on where just like above examples
```

---

### 🔄 FatEcto.Sort.Sortable – Effortless Sorting

Sorting should be simple—and with `Sortable`, it is! Your frontend can send sorting parameters, and FatEcto will seamlessly generate the right sorting queries, allowing you to build powerful, customizable sorting logic without breaking a sweat. 😎

#### Usage of FatSortable

```elixir
defmodule Fat.SortQuery do
  import Ecto.Query
  use FatEcto.Sort.Sortable,
    sortable: [id: "$ASC", name: ["$ASC", "$DESC"]],
    overrideable: ["custom_field"]

  @impl true
  def override_sortable(query, "custom_field", "$ASC") do
    from(q in query, order_by: [asc: fragment("?::jsonb->>'custom_field'", q)])
  end

  def override_sortable(query, _field, _operator) do
    query
  end
end
```

---

### 📌 FatEcto.Pagination.Paginator – Paginate Like a Pro

No more hassle with pagination! FatPaginator helps you paginate Ecto queries efficiently, keeping your APIs snappy and responsive.

#### Usage of FatPaginator

```elixir
defmodule Fat.MyPaginator do
  use FatEcto.Pagination.V2Paginator,
    default_limit: 10,
    repo: FatEcto.Repo,
    max_limit: 100
end
```

---

## 🚀 Contributing

We love contributions! If you’d like to improve FatEcto, submit an issue or pull request. Let’s build something amazing together! 🔥

---

## 📜 License

FatEcto is released under the MIT License.

📖 See the full documentation at [HexDocs](https://hexdocs.pm/fat_ecto/) for more details.
