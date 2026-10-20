# learning-haskell

A from-scratch JSON parser in Haskell, built as a vehicle for learning the language.

## Environment

`flake.nix` provides a dev shell with `ghc` (9.10.3) and `cabal-install` via nixpkgs. Enter it with:

```
nix develop
```

## Who's doing what

The user is learning Haskell through this project and wants to write the project
code themselves — Claude should teach and guide, not author the parser
implementation. Short illustrative snippets in explanations are fine; writing
the actual `.hs` files is not. Tooling/config (flake.nix, this file, cabal
project files, etc.) is fair game for Claude to write directly.

Session style: move slowly, prioritize *why* and *how* over just getting things
working. Let the user run commands and read errors themselves rather than
narrating results for them.

## Learning goals

- Primary: build deep intuition for Functor, Applicative, and Monad via the
  parser-combinator library. In practice the JSON grammar turned out not to
  *require* Monad — it's context-free, so Functor/Applicative/Alternative
  sufficed for all of it except one rule (see roadmap). Monad is still a
  planned, deliberate exercise.
- Secondary (not expected to come up in this project, planned as a follow-on):
  Foldable and Monoid.

## Status

Parser combinator library (`Parser.hs`) and full JSON grammar (`Json.hs`) are
done and working end-to-end: null, bool, number, string, array, object,
arbitrary nesting, whitespace tolerance. Verified against a realistic nested
document.

## Roadmap

Remaining JSON spec gaps, to close out the current phase:

- string escape sequences (`\"`, `\\`, `\n`, `\uXXXX`, ...)
- negative numbers
- exponent notation (`1e10`)
- reject leading zeros (`01` invalid) — the one validation rule that depends
  on *inspecting a parsed value* rather than a fixed grammar shape, so this is
  the planned motivated exercise for building Monad on `Parser`
- decide whether `parseJson` should require full input consumption (reject
  trailing garbage) rather than returning leftover input

Next, after the above: a small `main.hs` CLI to run the parser against a file
on disk, as its own exercise (argument handling, `IO`, reading a file).

After that, pick one direction via conversation:

1. *use* the parser for something, e.g. pretty-printing `JsonValue` back to text
2. parse a different config format (TOML/INI) reusing the combinator library
3. add line/column-aware error messages to the JSON parser
