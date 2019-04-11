defmodule FatEcto.TestRecordUtils do
  @moduledoc false
  use FatUtils.FatRecord, otp_app: :fat_ecto, encoder_library: Jason
end
