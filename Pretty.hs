module Pretty (prettyPrint) where

import Data.List (intercalate)
import Json (JsonValue (..))
import Numeric (showHex)
import Data.Char (ord)

prettyPrint :: JsonValue -> String
prettyPrint = go 0

go :: Int -> JsonValue -> String
go _ (JsonNum d) = showJsonNum d
go _ (JsonBool b) = if b then "true" else "false"
go _ JsonNull = "null"
go _ (JsonStr s) = showJsonStr s
go depth (JsonArray xs) = "[" ++ intercalate ", " (map (go depth) xs) ++ "]"
go _ (JsonObject []) = "{}"
go depth (JsonObject kvs) =
  "{\n" ++ intercalate ",\n" rows ++ "\n" ++ indent depth ++ "}"
  where
    rows = [indent (depth + 1) ++ show k ++ ": " ++ go (depth + 1) v | (k, v) <- kvs]

indent :: Int -> String
indent n = replicate (2 * n) ' '

showJsonNum :: Double -> String
showJsonNum d
  | d == fromInteger n = show n
  | otherwise = show d
  where
    n = round d

showJsonStr :: String -> String
showJsonStr s = "\"" ++ concatMap escape s ++ "\""

escapes :: [(Char, String)]
escapes = zip "\"\\\n\r\t\b\f" ["\\\"", "\\\\", "\\n", "\\r", "\\t", "\\b", "\\f"]

escape :: Char -> String
escape c = case lookup c escapes of
  Just e -> e
  Nothing
    | ord c < 0x20 -> "\\u" ++ pad4 (showHex (ord c) "")
    | otherwise    -> [c]
  where
    pad4 h = replicate (4 - length h) '0' ++ h
