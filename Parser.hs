module Parser where

import Control.Applicative
import Control.Monad (replicateM)
import Data.Bifunctor (first)
import Data.Char (chr, digitToInt, isDigit, isHexDigit, isSpace)

newtype Parser a = Parser {runParser :: String -> Maybe (a, String)}

instance Functor Parser where
  fmap f (Parser p) = Parser $ \s -> first f <$> p s

instance Applicative Parser where
  pure a = Parser $ \s -> Just (a, s)

  Parser pf <*> Parser pa = Parser $ \s -> do
    (f, s') <- pf s
    (a, s'') <- pa s'
    pure (f a, s'')

instance Alternative Parser where
  empty = Parser $ const Nothing

  Parser p <|> Parser q = Parser $ \s -> p s <|> q s

sat :: (Char -> Bool) -> Parser Char
sat f = Parser $ \s -> case s of
  c : cs | f c -> Just (c, cs)
  _ -> Nothing

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
parseStringLiteral = quote *> many stringChar <* quote
  where
    quote = sat (== '"')

    stringChar = escape <|> sat (/= '"')

    escape = sat (== '\\') *> (unicodeEscape <|> simpleEscape)

    unicodeEscape = sat (== 'u') *> (hexToChar <$> replicateM 4 (sat isHexDigit))

    simpleEscape =
      asum [r <$ sat (== c) | (c, r) <- zip "\"\\/bfnrt" "\"\\/\b\f\n\r\t"]

    hexToChar = chr . foldl' (\n d -> n * 16 + digitToInt d) 0

token :: Parser a -> Parser a
token p = many (sat isSpace) *> p <* many (sat isSpace)

sepBy1 :: Parser a -> Parser b -> Parser [a]
sepBy1 p sep = (:) <$> p <*> many (sep *> p)

sepBy :: Parser a -> Parser b -> Parser [a]
sepBy p sep = sepBy1 p sep <|> pure []
