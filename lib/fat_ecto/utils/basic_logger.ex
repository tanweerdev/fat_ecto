defmodule FatUtils.BasicLogger do
  require Logger

  def log_action_failed(data, title \\ "details", _opts \\ []) do
    Logger.error("#{title} => data: ##{inspect(data)}")
  end

  def log_action_success(data, title \\ "details", _opts \\ []) do
    Logger.debug("#{title} => data: ##{inspect(data)}")
  end
end
