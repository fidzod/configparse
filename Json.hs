module Json where

data JsonValue
  = JsonNum Double
  | JsonNull
  | JsonBool Bool
  | JsonStr String
  | JsonArray [JsonValue]
  | JsonObject [(String, JsonValue)]
  deriving (Show, Eq)
