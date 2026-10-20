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

parseJson :: Parser JsonValue
parseJson = token parseJsonValue

parseJsonValue :: Parser JsonValue
parseJsonValue =
  parseNull
    <|> parseBool
    <|> parseNumber
    <|> parseString
    <|> parseArray

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

-- todo: support for escape sequences
parseString :: Parser JsonValue
parseString = JsonStr <$> text
  where
    text = sat (== '"') *> many (sat (/= '"')) <* sat (== '"')

parseArray :: Parser JsonValue
parseArray =
  JsonArray
    <$> (openBracket *> elems <* closeBracket)
  where
    openBracket = token (sat (== '['))
    closeBracket = token (sat (== ']'))
    sep = (token (sat (== ',')))
    elems = sepBy (token parseJsonValue) sep
