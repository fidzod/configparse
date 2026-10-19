module Parser where

import Data.Char (isDigit, digitToInt)

type Parser a = String -> Maybe (a, String)

parseDigit :: Parser Int
parseDigit [] = Nothing
parseDigit (x:xs) = if isDigit x then Just (digitToInt x, xs) else Nothing
