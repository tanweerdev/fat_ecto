defmodule Paginator do
  @moduledoc """
  Paginator module can limit the number of records returned and also apply the offset and return meta information. You can use it inside a module.

  ```
    use FatEcto.FatPaginator, max_limit: 10, default_limit: 5
  ```

  """
  use FatEcto.FatPaginator, max_limit: 10, default_limit: 5
end
