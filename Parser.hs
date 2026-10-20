module Parser where

import Control.Applicative
import Data.Char (digitToInt, isDigit)

newtype Parser a = Parser {runParser :: String -> Maybe (a, String)}

instance Functor Parser where
  fmap g p =
    Parser
      ( \s -> case runParser p s of
          Nothing -> Nothing
          Just (a, rest) -> Just (g a, rest)
      )

instance Applicative Parser where
  pure a = Parser (\s -> Just (a, s))
  a <*> b =
    Parser
      ( \s -> case runParser a s of
          Nothing -> Nothing
          Just (f, rest1) -> case runParser b rest1 of
            Nothing -> Nothing
            Just (x, rest2) -> Just (f x, rest2)
      )

instance Alternative Parser where
  empty = Parser (\_ -> Nothing)
  a <|> b =
    Parser
      ( \s -> case runParser a s of
          Nothing -> runParser b s
          x -> x
      )

sat :: (Char -> Bool) -> Parser Char
sat f =
  Parser
    ( \s -> case s of
        [] -> Nothing
        (x : xs) -> if f x then Just (x, xs) else Nothing
    )

parseDigit :: Parser Int
parseDigit = digitToInt <$> sat isDigit

parseInt :: Parser Int
parseInt = read <$> some (sat isDigit)

parseDouble :: Parser Double
parseDouble = read <$> wholeNumber
  where
    wholeNumber = (++) <$> intPart <*> fracPart
    intPart = some (sat isDigit)
    fracPart = ((:) <$> sat (== '.') <*> intPart) <|> pure ""

string :: String -> Parser String
string [] = pure ""
string (x : xs) = (:) <$> sat (== x) <*> string xs

