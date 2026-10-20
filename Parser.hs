module Parser where

import Control.Applicative
import Control.Monad (replicateM)
import Data.Char (chr, digitToInt, isDigit, isHexDigit, isSpace)
import Numeric (readHex)

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

parseStringLiteral :: Parser String
parseStringLiteral = sat (== '"') *> ch <* sat (== '"')
  where
    ch = many (parseEscSeq <|> sat (/= '"'))
    parseEscSeq = parseUnicodeEscape <|> parseFixedEscape
    parseUnicodeEscape =
      (chr . read . ("0x" ++))
        <$> (string "\\u" *> replicateM 4 (sat isHexDigit))
    parseFixedEscape =
      foldr1 (<|>) $
        map (\(c, r) -> r <$ string ['\\', c]) pairs
    pairs =
      [ ('"', '"'),
        ('\\', '\\'),
        ('/', '/'),
        ('b', '\b'),
        ('f', '\f'),
        ('n', '\n'),
        ('r', '\r'),
        ('t', '\t')
      ]

token :: Parser a -> Parser a
token p = many (sat isSpace) *> p <* many (sat isSpace)

sepBy1 :: Parser a -> Parser b -> Parser [a]
sepBy1 p sep = (:) <$> p <*> many (sep *> p)

sepBy :: Parser a -> Parser b -> Parser [a]
sepBy p sep = sepBy1 p sep <|> pure []
