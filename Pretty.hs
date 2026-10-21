module Pretty (prettyPrint) where

import Data.List (intercalate)
import Json (JsonValue (..))

showJsonNum :: Double -> String
showJsonNum d
  | d == fromInteger n = show n
  | otherwise = show d
  where
    n = round d

prettyPrint :: JsonValue -> String
prettyPrint = go 0

go :: Int -> JsonValue -> String
go _ (JsonNum d) = showJsonNum d
go _ (JsonBool b) = if b then "true" else "false"
go _ JsonNull = "null"
go _ (JsonStr s) = show s
go depth (JsonArray xs) = "[" ++ intercalate ", " (map (go depth) xs) ++ "]"
go _ (JsonObject []) = "{}"
go depth (JsonObject kvs) =
  "{\n" ++ intercalate ",\n" rows ++ "\n" ++ indent depth ++ "}"
  where
    rows = [indent (depth + 1) ++ show k ++ ": " ++ go (depth + 1) v | (k, v) <- kvs]

indent :: Int -> String
indent n = replicate (2 * n) ' '
