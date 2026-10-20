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
    <|> parseObject

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

parseString :: Parser JsonValue
parseString = JsonStr <$> parseStringLiteral

parseArray :: Parser JsonValue
parseArray =
  JsonArray
    <$> (openBracket *> elems <* closeBracket)
  where
    openBracket = token (sat (== '['))
    closeBracket = token (sat (== ']'))
    sep = (token (sat (== ',')))
    elems = sepBy (token parseJsonValue) sep

parseObject :: Parser JsonValue
parseObject =
  JsonObject
    <$> (openBracket *> pairs <* closeBracket)
  where
    openBracket = token (sat (== '{'))
    closeBracket = token (sat (== '}'))
    pairs = sepBy pair (token (sat (== ',')))
    pair = ((,) <$> (token parseStringLiteral)) <* (token (sat (== ':'))) <*> (token parseJsonValue)
