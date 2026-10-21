module Main where

import Parser (Parser(runParser))
import Pretty (prettyPrint)
import Json (parseJson)
import System.Environment (getArgs)
import System.IO (hPutStrLn, stderr)
import System.Exit (exitFailure, die)

processFile :: FilePath -> IO ()
processFile path = do
  text <- readFile path
  case runParser parseJson text of
    Nothing     -> die "Failed to parse"
    Just (v, _) -> putStrLn $ prettyPrint v

main :: IO ()
main = do
  args <- getArgs
  case args of
    [path] -> processFile path
    _      -> die "Usage: configparse <json file>"
