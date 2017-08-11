defmodule DynamicEnv.KeyStore do 
  @moduledoc """
  Meant to store just the keys of environment variables. 
  This is to keep track of when keys are deleted that 
  the environment variables are removed too.
  """
  use GenServer

  def start_link do 
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def update_keys(keys) do
    GenServer.call(__MODULE__, {:update_keys, keys})
  end

  def get_keys do
    GenServer.call(__MODULE__, :get_keys)
  end

  def handle_call({:update_keys, keys}, _from, _state) do
    {:reply, keys, keys} 
  end

  def handle_call(:get_keys, _from, keys) do
    {:reply, keys, keys}
  end
end

