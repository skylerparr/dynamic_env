# DynamicEnv

This provides a way to store environment variables into AWS SSM keystore
backed by KMS encryption. Then you can invoke a function that will update
your environment variables without recompiling or restarting your application.

Be sure that you have your aws configuration variables set: 

```
config :dynamic_env, :aws_secret_key, System.get_env("AWS_SECRET_KEY")
config :dynamic_env, :aws_secret_access_key, System.get_env("AWS_SECRET_ACCESS_KEY")
```

First you need to generate a KMS key. You do that via:

```
iex> DynamicEnv.AWS.Util.generate_kms_key_id("my secret key name")
```

The output of that command will need to be part of the environment *before*
starting the web server. The environment variable will need to be set as

```
AWS_KMS_KEY="the value of my secret key"
```

From there you can use EnvConfig to set and update your environment
variables.

In your config.exs

```
config :my_app, :sample_var, {:system, "FOO_KEY"}
```

Keys can be set and fetched by a namespace (eg your environment)

```
iex> alias DynamicEnv.Environment
iex> Environment.put_param("my_app_staging", "FOO", "BAR")
:ok
iex> Environment.get_param("my_app_staging", "FOO")
"BAR"
```

Then you can refresh your environment and fetch via env_config

```
iex> Environment.refresh_environment("my_app_staging")
["FOO"]

iex> EnvConfig.get(:my_app, :sample_var)
"BAR"
```

When you want to update your environment variables you'll need 
to refresh once again

```
iex> Environment.put_param("my_app_staging", "FOO", "KABOOM")
:ok
iex> EnvConfig.get(:my_app, :sample_var)
"BAR"
iex> Environment.refresh_environment("my_app_staging")
["FOO"]
iex> EnvConfig.get(:my_app, :sample_var)
"KABOOM"
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `dynamic_env` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:dynamic_env, "~> 0.1.0"}]
end
```

and be sure to add it to your applications

```
def applications do
  [applications: [:dynamic_env]]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/dynamic_env](https://hexdocs.pm/dynamic_env).

