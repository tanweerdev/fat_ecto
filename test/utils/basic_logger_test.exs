defmodule Utils.BasicLoggerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  import FatUtils.BasicLogger

  test "log error message" do
    changeset = FatEcto.FatDoctor.changeset(%{phone: "12345", address: "testing"})

    assert capture_log(fn -> log_action_failed(changeset.errors) end) =~
             "details => data: #[name: {\"can't be blank\", [validation: :required]}, designation: {\"can't be blank\", [validation: :required]}]"
  end

  test "log sucess message" do
    changeset = FatEcto.FatDoctor.changeset(%{name: "John", designation: "testing"})
    assert capture_log(fn -> log_action_success(changeset.valid?) end) =~ ""
  end
end
