defmodule DynamicEnv do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # Start your own worker by calling: DeploymentTool.Worker.start_link(arg1, arg2, arg3)
      worker(DynamicEnv.KeyStore, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DynamicEnv.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
