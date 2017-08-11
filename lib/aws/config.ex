defmodule DynamicEnv.AWS.Config do 

  def config do
    %AWS.Client{
      access_key_id: Application.get_env(:dynamic_env, :aws_secret_key),
        secret_access_key: Application.get_env(:dynamic_env, :aws_secret_access_key),
        region: "us-east-1",
        endpoint: "amazonaws.com"
    }
  end

end

