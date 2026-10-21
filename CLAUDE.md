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

- `Parser.hs` / `Json.hs`: complete, spec-compliant JSON parser — null, bool,
  number (negatives, exponents, leading-zero rejection), string (escape
  sequences, `\uXXXX`), array, object, arbitrary nesting, whitespace
  tolerance, full-input-consumption at the top level. Tagged `v1`/`v2`.
- `Pretty.hs`: indentation-aware `JsonValue -> String` pretty printer,
  including correct JSON string escaping (the reverse of
  `parseStringLiteral`'s escape table).
- `Main.hs`: CLI entrypoint — reads a file, parses it, pretty-prints the
  result (or a usage/parse-failure message via `die`). Cabal project
  (`configparse.cabal`); pushed to GitHub (`fidzod/configparse`).
- `fixtures/`: `sample.json`, `edge-cases.json` (JSON), `sample.yaml` (YAML
  target, see below).

## Roadmap

Current phase: parse a subset of YAML, reusing and extending the combinator
library. Chosen deliberately over the earlier pretty-printer/TOML/line-column
options — YAML's indentation-significant block structure is genuinely
context-sensitive (whether a line belongs to the current block depends on a
previously-parsed indentation value), making it the first real, honest case
for building a `Monad` instance on `Parser`.

Scope, decided 2026-10-21: block-style mappings and sequences
(indentation-driven nesting), scalar types (string/int/float/bool/null), and
comments. Explicitly out of scope for now, to revisit by conversation once
the core subset works: flow style (`{a: 1}`/`[1,2]`), block scalars (`|`/`>`
with chomping indicators), anchors/aliases, tags, multi-document streams,
complex (`? ... :`) keys.

Target: `fixtures/sample.yaml` — build up the grammar incrementally until it
parses this file end to end.

After YAML's core subset works: pick a direction via conversation — options
raised so far include flow-style/anchors as YAML follow-ons, a different
config format (TOML/INI), or line/column-aware error messages.
