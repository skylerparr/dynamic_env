defmodule DynamicEnv.AWS.Util do
  import Dynamic.AWS.Config

  def generate_kms_key_id(key_name) do
    key_id = config()
    |> AWS.KMS.create_key(%{"Description": key_name})
    |> elem(1)
    |> Map.get("KeyMetadata")
    |> Map.get("KeyId")

    config()
    |> AWS.KMS.create_alias(%{"TargetKeyId": key_id, "AliasName": "alias/#{key_name}"})

    key_id
  end

end
