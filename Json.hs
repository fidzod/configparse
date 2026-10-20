module Json where

import Control.Applicative
import Parser

data JsonValue
  = JsonNum Double
  | JsonNull
  | JsonBool Bool
  | JsonStr String
  | JsonArray [JsonValue]
  | JsonObject [(String, JsonValue)]
  deriving (Show, Eq)

parseNull :: Parser JsonValue
parseNull = JsonNull <$ string "null"

parseBool :: Parser JsonValue
parseBool = parseTrue <|> parseFalse
  where
    parseTrue :: Parser JsonValue
    parseTrue = JsonBool True <$ string "true"
    parseFalse :: Parser JsonValue
    parseFalse = JsonBool False <$ string "false"

parseNumber :: Parser JsonValue
parseNumber = JsonNum <$> parseDouble

parseJsonValue :: Parser JsonValue
parseJsonValue =
  parseNull
    <|> parseBool
    <|> parseNumber
    <|> parseString

-- todo: support for escape sequences
parseString :: Parser JsonValue
parseString = JsonStr <$> text
  where
    text = sat (== '"') *> many (sat (/= '"')) <* sat (== '"')
