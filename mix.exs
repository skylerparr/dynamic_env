defmodule DynamicEnv.Mixfile do
  use Mix.Project

  def project do
    [app: :dynamic_env,
     version: "0.1.0",
     elixir: "~> 1.4",
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [mod: {DynamicEnv, []},
		 applications: [:poison, :aws, :env_config], 
		 extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:aws, "~> 0.5.0"},
      {:env_config, "~> 0.1.0"}
    ]
  end

  defp package do
    [
      name: :dynamic_env,
      files: ["lib", "mix.exs", "README*", "LICENSE*", "config"],
      maintainers: ["Skyler Parr"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/skylerparr/dynamic_env"}
    ]
  end
end
