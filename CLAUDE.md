# configparse

A from-scratch parser-combinator library in Haskell (JSON now, YAML planned),
built as a vehicle for learning the language.

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
  parser-combinator library. In practice, nothing in the JSON grammar ended up
  *requiring* Monad — it's entirely context-free, so Functor/Applicative/
  Alternative sufficed for all of it, including leading-zero rejection once
  `int` was shaped as `"0" | digit19 *DIGIT` rather than "parse digits, then
  inspect." This generalizes: Monad only earns its keep on context-sensitive
  grammars (what you parse next depends on an already-parsed *value*, e.g. a
  length-prefixed string), which JSON/TOML/INI aren't. Monad on `Parser` is
  still a planned, deliberate exercise — likely a small standalone toy parser
  (e.g. length-prefixed strings) rather than something JSON forces on us.
- Secondary (not expected to come up in this project, planned as a follow-on):
  Foldable and Monoid.

## Status

Parser combinator library (`Parser.hs`) and full JSON grammar (`Json.hs`) are
complete and spec-compliant: null, bool, number (incl. negatives, exponents,
leading-zero rejection), string (incl. escape sequences and `\uXXXX`), array,
object, arbitrary nesting, whitespace tolerance. Tagged `v1` (initial working
parser) and `v2` (full number/string spec compliance + instance cleanup).

## Roadmap

`parseJson` now requires full input consumption (an `eof` primitive, `<*`'d
onto the end) — trailing garbage is rejected rather than silently left over.

Next: a small `main.hs` CLI to run the parser against a file on disk, as its
own exercise (argument handling, `IO`, reading a file).

After that: parse a subset of YAML, reusing and extending the combinator
library. Chosen deliberately over the earlier pretty-printer/TOML/line-column
options — YAML's indentation-significant block structure is genuinely
context-sensitive (whether a line belongs to the current block depends on a
previously-parsed indentation value), which is the first real, honest case
for building a `Monad` instance on `Parser`. Approach: start from a concrete
target YAML snippet (decide this once `main.hs` is done) and build up the
grammar incrementally until it parses.

After that, pick one direction via conversation:

1. *use* the parser for something, e.g. pretty-printing `JsonValue` back to text
2. parse a different config format (TOML/INI) reusing the combinator library
3. add line/column-aware error messages to the JSON parser
