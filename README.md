# FatEcto: Supercharge Your Ecto Queries with Ease! 🚀


[![Build Status](https://github.com/tanweerdev/fat_ecto/actions/workflows/fat_ecto.yml/badge.svg)](https://github.com/tanweerdev/fat_ecto/actions)
[![Coverage Status](https://coveralls.io/repos/github/tanweerdev/fat_ecto/badge.svg)](https://coveralls.io/github/tanweerdev/fat_ecto)
[![hex.pm version](https://img.shields.io/hexpm/v/fat_ecto.svg)](https://hex.pm/packages/fat_ecto)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/fat_ecto.svg)](https://hex.pm/packages/fat_ecto)
[![hex.pm license](https://img.shields.io/hexpm/l/fat_ecto.svg)](https://github.com/tanweerdev/fat_ecto/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/tanweerdev/fat_ecto.svg)](https://github.com/tanweerdev/fat_ecto/commits/master)

## Description

FatEcto is an Elixir package designed to make your life easier when working with Ecto. It simplifies query building, filtering, sorting, pagination, and data sanitization—so you can focus on what truly matters: building amazing applications. With FatEcto, writing complex queries becomes effortless, flexible, and powerful! 💪

## Installation

Getting started is simple! Add `fat_ecto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # Check https://hexdocs.pm/fat_ecto for the latest version
    {:fat_ecto, "~> 1.0.0"}
  ]
end
```

Then, run `mix deps.get` to install the package.

## Features & Modules

### 🛠 FatEcto.FatQuery.Whereable – Dynamic Filtering Made Easy

Tired of writing repetitive query filters? The `Whereable` module lets you dynamically filter records using flexible conditions passed from your web or mobile clients—with little to no effort! And the best part? You stay in control. 🚀

#### Usage

```elixir
defmodule MyApp.HospitalFilter do
  use FatEcto.FatQuery.Whereable,
    filterable_fields: %{
      "id" => ["$eq", "$neq"]
    },
    overrideable_fields: ["name", "phone"],
    ignoreable_fields_values: %{
      "name" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }

  import Ecto.Query

  # You can implement override_whereable for your custom filters
  def override_whereable(query, "name", "$ilike", value) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.name), ^value))
  end

  def override_whereable(query, _, _, _), do: query
end
```

##### Example Usage

```elixir
opts = %{"name" => %{"$like" => "%St. Mary%"}}
query = HospitalFilter.build(FatEcto.FatHospital, opts)

result = from(h in FatEcto.FatHospital, where: like(fragment("(?)::TEXT", h.name), ^"%St. Mary%"))
```

### 🔄 FatEcto.FatQuery.Sortable – Effortless Sorting

Sorting should be simple—and with `Sortable`, it is! Your frontend can send sorting parameters, and FatEcto will seamlessly generate the right sorting queries, allowing you to build powerful, customizable sorting logic without breaking a sweat. 😎

#### Usage

```elixir
defmodule MyApp.SortQuery do
  import Ecto.Query
  use FatEcto.FatQuery.Sortable,
    sortable_fields: %{"id" => "$asc", "name" => ["$asc", "$desc"]},
    overrideable_fields: ["custom_field"]

  @impl true
  def override_sortable(query, field, operator) do
    case {field, operator} do
      {"custom_field", "$asc"} ->
        from(q in query, order_by: [asc: fragment("?::jsonb->>'custom_field'", q)])
      _ ->
        query
    end
  end
end
```

### 📌 FatEcto.FatPaginator – Paginate Like a Pro

No more hassle with pagination! FatPaginator helps you paginate Ecto queries efficiently, keeping your APIs snappy and responsive.

#### Usage

```elixir
defmodule MyApp.MyPaginator do
  use FatEcto.FatPaginator, repo: MyApp.Repo
  # Add custom pagination functions here
end
```

### 🔍 FatEcto.DataSanitizer – Clean & Structured Data

Messy data? Not anymore! `DataSanitizer` helps you sanitize records and transform them into structured, clean views effortlessly. Keep your data tidy and consistent. 🎯

#### Usage

```elixir
defmodule MyApp.MySanitizer do
  use FatEcto.DataSanitizer
  # Define your custom sanitization functions here
end
```

### ⚡ FatEcto Utilities – Small Helpers, Big Impact

FatEcto also comes with a set of handy utility functions to streamline your workflow:

```elixir
# Check if a map contains all required keys
FatUtils.Map.has_all_keys?(%{a: 1, b: 2}, [:a, :b])

# Ensure a map contains only allowed keys
FatUtils.Map.contain_only_allowed_keys?(%{a: 1, c: 3}, [:a, :b])
```

## 🚀 Contributing

We love contributions! If you’d like to improve FatEcto, submit an issue or pull request. Let’s build something amazing together! 🔥

## 📜 License

FatEcto is released under the MIT License.

📖 See the full documentation at [HexDocs](https://hexdocs.pm/fat_ecto/) for more details.
