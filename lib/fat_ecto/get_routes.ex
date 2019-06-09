defmodule FatEcto.Routes do
  use Mix.Task
  alias Phoenix.Router.ConsoleFormatter

  @shortdoc "Get all routes"

  @moduledoc """
  Get all routes for the default or a given router.
  routes = FatEcto.Routes.get_routes [HaiApi.Router]
  The default router is inflected from the application
  name unless a configuration named `:namespace`
  is set inside your application configuration. For example,
  the configuration:
      config :my_app,
        namespace: My.App
  will exhibit the routes for `My.App.Router` when this
  task is invoked without arguments.
  Umbrella projects do not have a default router and
  therefore always expect a router to be given.
  """

  # TODO: write tests if possible
  @doc false
  def get_routes(args, base \\ Mix.Phoenix.base()) do
    Mix.Task.run("compile", args)

    {router_mod, opts} =
      case OptionParser.parse(args, switches: [enpdoint: :string, router: :string]) do
        {opts, [passed_router], _} -> {router(passed_router, base), opts}
        {opts, [], _} -> {router(opts[:router], base), opts}
      end

    str_paths = router_mod
    |> ConsoleFormatter.format(endpoint(opts[:endpoint], base))
    # |> Mix.shell.info()

    # Code to return path list

    # TODO: currently it returns options array as string eg
    # ["*", "/api/swagger", "PhoenixSwagger.Plug.SwaggerUI", "[otp_app:", ":api,",
    #  "swagger_file:", "\"swagger_manual.json\"]"],
    # TODO: parse options and convert into array before splitting array
    path_list = String.split(str_paths, "\n")
    Enum.reduce(path_list,[], fn path, acc ->
      acc ++ [String.split(path)]
    end)
  end

  defp endpoint(nil, base) do
    loaded(web_mod(base, "Endpoint"))
  end
  defp endpoint(module, _base) do
    loaded(Module.concat([module]))
  end

  defp router(nil, base) do
    if Mix.Project.umbrella?() do
      Mix.raise """
      umbrella applications require an explicit router to be given to phx.routes, for example:
          $ mix phx.routes MyAppWeb.Router
      """
    end
    web_router = web_mod(base, "Router")
    old_router = app_mod(base, "Router")

    loaded(web_router) || loaded(old_router) || Mix.raise """
    no router found at #{inspect web_router} or #{inspect old_router}.
    An explicit router module may be given to phx.routes, for example:
        $ mix phx.routes MyAppWeb.Router
    """
  end
  defp router(router_name, _base) do
    arg_router = Module.concat([router_name])
    loaded(arg_router) || Mix.raise "the provided router, #{inspect(arg_router)}, does not exist"
  end

  defp loaded(module) do
    if Code.ensure_loaded?(module), do: module
  end

  defp app_mod(base, name), do: Module.concat([base, name])

  defp web_mod(base, name), do: Module.concat(["#{base}Web", name])
end
