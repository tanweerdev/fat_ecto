defmodule SanitizeRecord do
  @moduledoc """
  This module sanitize the response by removing structs that are not loaded alognwith meta. It supports lists of maps, tuples and map.

  ```
   use FatUtils.FatRecord, otp_app: :app_name, encoder_library: encode_library
  ```

  """
  use FatUtils.FatRecord, otp_app: :fat_ecto, encoder_library: Jason
end
