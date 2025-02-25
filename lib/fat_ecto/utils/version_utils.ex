defmodule FatUtils.Version do
  @moduledoc """
  Provides utilities for retrieving and parsing Git version information.

  This module allows you to fetch details about the current Git commit, such as:
  - Commit hash
  - Commit message
  - Commit author
  - Commit date
  - Current branch

  ## Example Usage

      iex> FatUtils.Version.get_version_info()
      %{
        commit_hash: "a1b2c3d",
        commit_message: "Add new feature",
        commit_author: "John Doe",
        commit_date: "Mon Oct 2 12:34:56 2023 +0000",
        branch: "main"
      }
  """

  @doc """
  Retrieves and parses Git version information.

  Returns a map containing the following keys:
  - `:commit_hash`: The short commit hash.
  - `:commit_message`: The commit message.
  - `:commit_author`: The commit author's name.
  - `:commit_date`: The commit date in the default Git format.
  - `:branch`: The current branch name.

  If the `git` command fails, returns `nil`.

  ## Example

      iex> FatUtils.Version.get_version_info()
      %{
        commit_hash: "a1b2c3d",
        commit_message: "Add new feature",
        commit_author: "John Doe",
        commit_date: "Mon Oct 2 12:34:56 2023 +0000",
        branch: "main"
      }
  """
  @spec get_version_info ::
          %{
            commit_hash: String.t(),
            commit_message: String.t(),
            commit_author: String.t(),
            commit_date: String.t(),
            branch: String.t()
          }
          | nil
  def get_version_info do
    with {:ok, commit_hash} <- execute_git_command("show", ["-s", "--pretty=format:%h"]),
         {:ok, commit_message} <- execute_git_command("show", ["-s", "--pretty=format:%s"]),
         {:ok, commit_author} <- execute_git_command("show", ["-s", "--pretty=format:%cn"]),
         {:ok, commit_date} <- execute_git_command("show", ["-s", "--pretty=format:%cd"]),
         {:ok, branch} <- execute_git_command("rev-parse", ["--abbrev-ref", "HEAD"]) do
      %{
        commit_hash: commit_hash,
        commit_message: commit_message,
        commit_author: commit_author,
        commit_date: commit_date,
        branch: branch
      }
    else
      _ -> nil
    end
  end

  @doc """
  Executes a Git command and returns the trimmed output.

  ## Parameters
    - `command`: The Git command to execute (e.g., `"show"`).
    - `args`: A list of arguments for the command.

  ## Returns
    - `{:ok, output}` if the command succeeds.
    - `:error` if the command fails.

  ## Examples

      iex> FatUtils.Version.execute_git_command("show", ["-s", "--pretty=format:%h"])
      {:ok, "a1b2c3d"}
  """
  @spec execute_git_command(String.t(), list(String.t())) :: {:ok, String.t()} | :error
  def execute_git_command(command, args) do
    case System.cmd("git", [command | args]) do
      {output, 0} -> {:ok, String.trim_trailing(output)}
      _ -> :error
    end
  end

  @spec read_version_info(String.t()) :: any()
  def read_version_info(priv_path) do
    {_, version_info} = [priv_path, "version_info.json"] |> Path.join() |> File.read()
    Jason.decode!(version_info)
  end
end
