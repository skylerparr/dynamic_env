defmodule DynamicEnv.Environment do 
  import DynamicEnv.AWS.Config

  alias DynamicEnv.KeyStore

  def refresh_environment(env_name) do 
    env_name
    |> get_all_vars
    |> update_environment
  end

  def update_environment(env_vars) do 
    keys = KeyStore.get_keys
    Enum.each(env_vars, fn(var) ->
      System.put_env(var.name, var.value)
    end)
    Enum.each(keys, fn(key) -> 
      var = Enum.find(env_vars, fn(map) ->
        map.name == key
      end)
      if(var == nil) do
        :os.unsetenv(key)
      end
    end)
    keys = Enum.into(env_vars, [], fn(var) ->
      var.name
    end)
    KeyStore.update_keys(keys)
  end

  def get_all_keys(prefix) do 
    {:ok, %{"Parameters" => result}, _} = config()
    |> AWS.SSM.get_parameters(%{"Names": ["#{prefix}.__all_keys__"], "WithDecryption": true})

    if(result == []) do
      []
    else
      Poison.Parser.parse!(Map.get(result |> hd, "Value"))
    end
  end

  @spec put_param(String.t, String.t, String.t) :: :ok
  def put_param(prefix, name, value) do
    config()
    |> AWS.SSM.put_parameter(%{"Name": "#{prefix}.#{name}", "Value": value, "KeyId": key_id(), "Type": "SecureString", "Overwrite": true})

    prefix
    |> get_all_keys()
    |> MapSet.new
    |> MapSet.put(name)
    |> MapSet.to_list
    |> update_all_keys(prefix)

    :ok
  end

  def get_param(prefix, name) do
    {:ok, %{"Parameters" => result}, _} = config()
    |> AWS.SSM.get_parameters(%{"Names": ["#{prefix}.#{name}"], "WithDecryption": true})

    if(result == []) do
      nil
    else
      Map.get(result |> hd, "Value")
    end
  end

  def get_all_vars(prefix) do
    results = get_all_keys(prefix)
    |> Enum.into([], fn(key) ->
      :timer.sleep(60)
      Task.async(fn() -> 
        value = get_param(prefix, key)
        %{name: key, value: value}
      end)
    end)
    |> Task.yield_many(15_000)
    |> Enum.map(fn({task, res}) ->
      res || Task.shutdown(task, :brutal_kill)   
    end)
    
    for {:ok, value} <- results do
      value
    end
  end

  def delete_param(prefix, name) do
    config()
    |> AWS.SSM.delete_parameter(%{"Name": "#{prefix}.#{name}"})

    prefix
    |> get_all_keys()
    |> MapSet.new
    |> MapSet.delete(name)
    |> MapSet.to_list
    |> update_all_keys(prefix)

    :ok
  end

  def delete_all(prefix) do
    prefix
    |> get_all_keys()
    |> Enum.each(fn(key) ->
      delete_param(prefix, key)
    end)
  end

  defp update_all_keys(list, prefix) do
    config()
    |> AWS.SSM.put_parameter(%{"Name": "#{prefix}.__all_keys__", "Value": list |> Poison.encode!, "KeyId": key_id(), "Type": "SecureString", "Overwrite": true})
  end

  defp key_id do
    Application.get_env(:deployment_tool, :kms_key)
  end
end 

